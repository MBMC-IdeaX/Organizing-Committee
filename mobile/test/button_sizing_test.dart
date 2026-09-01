import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_dimensions.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/shared/widgets/primary_button.dart';
import 'package:ideax_judging/shared/widgets/secondary_button.dart';
import 'package:ideax_judging/features/judge/presentation/widgets/criterion_score_control.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PrimaryButton renders with height 48px', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              text: 'Add Team',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.byType(PrimaryButton);
    expect(buttonFinder, findsOneWidget);

    final Size size = tester.getSize(buttonFinder);
    expect(size.height, AppDimensions.buttonHeight);
    expect(size.height, 48.0);
  });

  testWidgets('SecondaryButton renders with compact height 42px', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: SecondaryButton(
              text: 'Save Draft',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.byType(SecondaryButton);
    expect(buttonFinder, findsOneWidget);

    final Size size = tester.getSize(buttonFinder);
    expect(size.height, AppDimensions.compactButtonHeight);
    expect(size.height, 42.0);
  });

  testWidgets('CriterionScoreControl renders cleanly without inner boxes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: CriterionScoreControl(
              criteriaId: 1,
              criteriaName: 'Innovation',
              maxScore: 20,
              score: 15,
              isReadOnly: false,
              onScoreChanged: (_) {},
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
