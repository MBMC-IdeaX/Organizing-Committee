import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/core/errors/app_exception.dart';
import 'package:ideax_judging/features/admin/domain/entities/admin_summary_entity.dart';
import 'package:ideax_judging/features/admin/domain/entities/team_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/teams_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/screens/teams_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockAdminRepository mockAdminRepository;
  late TeamsCubit teamsCubit;
  late AdminDashboardCubit adminDashboardCubit;

  const testTeam1 = TeamEntity(
    id: 1,
    teamName: 'Team Alpha',
    projectName: 'Smart Grid',
    idea: 'Clean Energy',
    displayOrder: 1,
    active: true,
  );

  const testTeam2 = TeamEntity(
    id: 2,
    teamName: 'Team Beta',
    projectName: 'Health AI',
    idea: 'Medical Diagnostic',
    displayOrder: 2,
    active: true,
  );

  const testSummary = AdminSummaryEntity(
    totalTeams: 2,
    activeTeams: 2,
    totalCriteria: 3,
    activeCriteria: 3,
    totalMaxScore: 60,
    totalJudges: 2,
    activeJudges: 2,
    readyForJudging: true,
  );

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    when(() => mockAdminRepository.getTeams()).thenAnswer((_) async => [testTeam1, testTeam2]);
    when(() => mockAdminRepository.getDashboardSummary()).thenAnswer((_) async => testSummary);

    teamsCubit = TeamsCubit(adminRepository: mockAdminRepository);
    adminDashboardCubit = AdminDashboardCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    teamsCubit.close();
    adminDashboardCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TeamsCubit>.value(value: teamsCubit),
        BlocProvider<AdminDashboardCubit>.value(value: adminDashboardCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const TeamsScreen(),
      ),
    );
  }

  testWidgets('TeamsScreen renders delete action buttons', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Team Alpha'), findsOneWidget);
    expect(find.text('Team Beta'), findsOneWidget);
    expect(find.text('Delete'), findsNWidgets(2));
  });

  testWidgets('Clicking Delete opens confirmation dialog and Cancel dismisses it', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Team?'), findsOneWidget);
    expect(find.textContaining('permanently delete Team Alpha'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Team?'), findsNothing);
    verifyNever(() => mockAdminRepository.deleteTeam(any()));
  });

  testWidgets('Confirming delete invokes repository and removes team', (tester) async {
    when(() => mockAdminRepository.deleteTeam(1)).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // Tap confirm delete in dialog
    final deleteDialogButton = find.widgetWithText(ElevatedButton, 'Delete');
    await tester.tap(deleteDialogButton);
    await tester.pumpAndSettle();

    verify(() => mockAdminRepository.deleteTeam(1)).called(1);
    expect(find.text('Team Alpha'), findsNothing);
    expect(find.text('Team Beta'), findsOneWidget);
  });

  testWidgets('Delete conflict 409 displays Cannot Delete Team dialog and allows Force Delete', (tester) async {
    when(() => mockAdminRepository.deleteTeam(1, force: false)).thenThrow(
      const ConflictException(
        message: 'Judging records exist',
        errorCode: 'TEAM_HAS_JUDGING_RECORDS',
      ),
    );
    when(() => mockAdminRepository.deleteTeam(1, force: true)).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    final deleteDialogButton = find.widgetWithText(ElevatedButton, 'Delete');
    await tester.tap(deleteDialogButton);
    await tester.pumpAndSettle();

    expect(find.text('Cannot Delete Team'), findsOneWidget);
    expect(find.textContaining('Judging records already exist for "Team Alpha"'), findsOneWidget);
    expect(find.text('Force Delete'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Deactivate'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Force Delete'));
    await tester.pumpAndSettle();

    verify(() => mockAdminRepository.deleteTeam(1, force: true)).called(1);
    expect(find.text('Cannot Delete Team'), findsNothing);
    expect(find.text('Team Alpha'), findsNothing);
  });
}
