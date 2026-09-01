import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/core/errors/app_exception.dart';
import 'package:ideax_judging/features/admin/presentation/widgets/reset_system_dialog.dart';

void main() {
  Widget buildTestWidget({
    required Future<bool> Function({
      required String adminPassword,
      required bool clearJudgings,
      required bool clearJudges,
      required bool clearTeams,
    }) onConfirm,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ResetSystemDialog(onConfirm: onConfirm),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );
  }

  testWidgets('ResetSystemDialog renders all elements and default checkbox state', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async => true,
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Competition Data'), findsOneWidget);
    expect(find.text('Clear all evaluation scores & ballots'), findsOneWidget);
    expect(find.text('Delete all judge accounts'), findsOneWidget);
    expect(find.text('Delete all participating teams'), findsOneWidget);
    expect(find.text('Admin Password'), findsOneWidget);
    expect(find.text('Authorize Reset'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('ResetSystemDialog validates empty password', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async => true,
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap Authorize Reset without entering password
    await tester.tap(find.text('Authorize Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your administrator password.'), findsOneWidget);
  });

  testWidgets('ResetSystemDialog requires secondary confirmation and submits successfully', (tester) async {
    String? submittedPassword;
    bool? submittedJudgings;
    bool? submittedJudges;
    bool? submittedTeams;

    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async {
        submittedPassword = adminPassword;
        submittedJudgings = clearJudgings;
        submittedJudges = clearJudges;
        submittedTeams = clearTeams;
        return true;
      },
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Check judge deletion checkbox
    await tester.tap(find.text('Delete all judge accounts'));
    await tester.pumpAndSettle();

    // Enter password
    await tester.enterText(find.byType(TextFormField), 'MyAdminSecretPass123!');
    await tester.pumpAndSettle();

    // Authorize reset -> opens secondary confirmation
    await tester.tap(find.text('Authorize Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Are you absolutely sure?'), findsOneWidget);
    expect(find.text('Reset Competition'), findsOneWidget);

    // Confirm secondary dialog
    await tester.tap(find.text('Reset Competition'));
    await tester.pumpAndSettle();

    expect(submittedPassword, 'MyAdminSecretPass123!');
    expect(submittedJudgings, true);
    expect(submittedJudges, true);
    expect(submittedTeams, false);

    // Dialog closed
    expect(find.text('Reset Competition Data'), findsNothing);
  });

  testWidgets('Cancelling secondary confirmation leaves dialog open without submitting', (tester) async {
    bool wasSubmitted = false;

    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async {
        wasSubmitted = true;
        return true;
      },
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Password123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authorize Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Are you absolutely sure?'), findsOneWidget);

    // Click Cancel on confirmation dialog
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    expect(wasSubmitted, false);
    expect(find.text('Reset Competition Data'), findsOneWidget);
  });

  testWidgets('ResetSystemDialog displays user-friendly message on invalid password failure', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async {
        throw const UnauthorizedException(
          message: 'Invalid password',
          statusCode: 401,
        );
      },
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'WrongPass');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authorize Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Competition'));
    await tester.pumpAndSettle();

    expect(find.text('Administrator verification failed. Please check your password.'), findsOneWidget);
  });

  testWidgets('ResetSystemDialog displays user-friendly message on network failure', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async {
        throw const NetworkException(message: 'Connection timed out');
      },
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Password123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authorize Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Competition'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to connect to the server. Please check your connection.'), findsOneWidget);
  });

  testWidgets('ResetSystemDialog displays user-friendly message on server error', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      onConfirm: ({
        required adminPassword,
        required clearJudgings,
        required clearJudges,
        required clearTeams,
      }) async {
        throw const ServerException(message: 'Internal server error', statusCode: 500);
      },
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Password123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authorize Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Competition'));
    await tester.pumpAndSettle();

    expect(find.text('Reset could not be completed. No changes were applied.'), findsOneWidget);
  });
}
