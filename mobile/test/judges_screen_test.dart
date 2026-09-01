import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/core/errors/app_exception.dart';
import 'package:ideax_judging/features/admin/domain/entities/admin_summary_entity.dart';
import 'package:ideax_judging/features/admin/domain/entities/judge_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/judges_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/screens/judges_screen.dart';
import 'package:ideax_judging/shared/models/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockAdminRepository mockAdminRepository;
  late JudgesCubit judgesCubit;
  late AdminDashboardCubit adminDashboardCubit;

  const testJudge1 = JudgeEntity(
    id: 1,
    username: 'judge_sarah',
    role: UserRole.judge,
    active: true,
  );

  const testJudge2 = JudgeEntity(
    id: 2,
    username: 'judge_alex',
    role: UserRole.judge,
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
    when(() => mockAdminRepository.getJudges()).thenAnswer((_) async => [testJudge1, testJudge2]);
    when(() => mockAdminRepository.getDashboardSummary()).thenAnswer((_) async => testSummary);

    judgesCubit = JudgesCubit(adminRepository: mockAdminRepository);
    adminDashboardCubit = AdminDashboardCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    judgesCubit.close();
    adminDashboardCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JudgesCubit>.value(value: judgesCubit),
        BlocProvider<AdminDashboardCubit>.value(value: adminDashboardCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const JudgesScreen(),
      ),
    );
  }

  testWidgets('JudgesScreen renders delete action buttons', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('judge_sarah'), findsOneWidget);
    expect(find.text('judge_alex'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(2));
  });

  testWidgets('Clicking Delete opens confirmation dialog and Cancel dismisses it', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Judge?'), findsOneWidget);
    expect(find.textContaining('permanently delete judge_sarah'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Judge?'), findsNothing);
    verifyNever(() => mockAdminRepository.deleteJudge(any()));
  });

  testWidgets('Confirming delete invokes repository and removes judge', (tester) async {
    when(() => mockAdminRepository.deleteJudge(1)).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    final deleteDialogButton = find.widgetWithText(ElevatedButton, 'Delete');
    await tester.tap(deleteDialogButton);
    await tester.pumpAndSettle();

    verify(() => mockAdminRepository.deleteJudge(1)).called(1);
    expect(find.text('judge_sarah'), findsNothing);
    expect(find.text('judge_alex'), findsOneWidget);
  });

  testWidgets('Delete conflict 409 displays Cannot Delete Judge dialog and allows Force Delete', (tester) async {
    when(() => mockAdminRepository.deleteJudge(1, force: false)).thenThrow(
      const ConflictException(
        message: 'Judging records exist',
        errorCode: 'JUDGE_HAS_JUDGING_RECORDS',
      ),
    );
    when(() => mockAdminRepository.deleteJudge(1, force: true)).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    final deleteDialogButton = find.widgetWithText(ElevatedButton, 'Delete');
    await tester.tap(deleteDialogButton);
    await tester.pumpAndSettle();

    expect(find.text('Cannot Delete Judge'), findsOneWidget);
    expect(find.textContaining('This judge (judge_sarah) has evaluation history'), findsOneWidget);
    expect(find.text('Force Delete'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Deactivate'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Force Delete'));
    await tester.pumpAndSettle();

    verify(() => mockAdminRepository.deleteJudge(1, force: true)).called(1);
    expect(find.text('Cannot Delete Judge'), findsNothing);
    expect(find.text('judge_sarah'), findsNothing);
  });
}
