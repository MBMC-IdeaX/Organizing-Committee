import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/auth/domain/repositories/auth_repository.dart';
import 'package:ideax_judging/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ideax_judging/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_fonts/google_fonts.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.onSessionExpired)
        .thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(authRepository: mockAuthRepository),
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all login fields and buttons properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In to IdeaX'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty on submit', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final loginButton = find.text('Sign In to IdeaX');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
