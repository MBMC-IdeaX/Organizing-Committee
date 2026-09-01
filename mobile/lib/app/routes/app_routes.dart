import 'package:flutter/material.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/criteria_screen.dart';
import '../../features/admin/presentation/screens/judges_screen.dart';
import '../../features/admin/presentation/screens/results_dashboard_screen.dart';
import '../../features/admin/presentation/screens/team_result_details_screen.dart';
import '../../features/admin/presentation/screens/teams_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/judge/domain/entities/judging_session_entity.dart';
import '../../features/judge/presentation/screens/judge_completion_screen.dart';
import '../../features/judge/presentation/screens/judge_dashboard_screen.dart';
import '../../features/judge/presentation/screens/judge_project_details_screen.dart';
import '../../features/judge/presentation/screens/scoring_screen.dart';
import 'route_names.dart';

class AppRoutes {
  AppRoutes._();

  static Map<String, WidgetBuilder> get routes => {
        RouteNames.splash: (context) => const SplashScreen(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.adminDashboard: (context) => const AdminDashboardScreen(),
        RouteNames.adminTeams: (context) => const TeamsScreen(),
        RouteNames.adminCriteria: (context) => const CriteriaScreen(),
        RouteNames.adminJudges: (context) => const JudgesScreen(),
        RouteNames.adminResults: (context) => const ResultsDashboardScreen(),
        RouteNames.judgeDashboard: (context) => const JudgeDashboardScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case RouteNames.adminTeams:
        return MaterialPageRoute(builder: (_) => const TeamsScreen());
      case RouteNames.adminCriteria:
        return MaterialPageRoute(builder: (_) => const CriteriaScreen());
      case RouteNames.adminJudges:
        return MaterialPageRoute(builder: (_) => const JudgesScreen());
      case RouteNames.adminResults:
        return MaterialPageRoute(builder: (_) => const ResultsDashboardScreen());
      case RouteNames.adminResultsTeamDetails:
        final teamId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => TeamResultDetailsScreen(teamId: teamId),
        );
      case RouteNames.judgeDashboard:
        return MaterialPageRoute(builder: (_) => const JudgeDashboardScreen());
      case RouteNames.judgeProjectDetails:
        final teamId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => JudgeProjectDetailsScreen(teamId: teamId),
        );
      case RouteNames.judgeScoring:
        final teamId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => ScoringScreen(teamId: teamId),
        );
      case RouteNames.judgeCompleted:
        final session = settings.arguments as JudgingSessionEntity;
        return MaterialPageRoute(
          builder: (_) => JudgeCompletionScreen(session: session),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
