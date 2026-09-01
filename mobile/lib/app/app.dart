import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/domain/repositories/results_repository.dart';
import '../features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import '../features/admin/presentation/cubit/criteria_cubit.dart';
import '../features/admin/presentation/cubit/judges_cubit.dart';
import '../features/admin/presentation/cubit/results_dashboard_cubit.dart';
import '../features/admin/presentation/cubit/team_result_cubit.dart';
import '../features/admin/presentation/cubit/teams_cubit.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/judge/domain/repositories/judge_repository.dart';
import '../features/judge/presentation/cubit/judge_dashboard_cubit.dart';
import '../features/judge/presentation/cubit/judging_cubit.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class IdeaXApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final JudgeRepository judgeRepository;
  final ResultsRepository resultsRepository;

  const IdeaXApp({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.judgeRepository,
    required this.resultsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<AdminRepository>.value(value: adminRepository),
        RepositoryProvider<JudgeRepository>.value(value: judgeRepository),
        RepositoryProvider<ResultsRepository>.value(value: resultsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository: authRepository),
        ),
        BlocProvider<AdminDashboardCubit>(
          create: (context) => AdminDashboardCubit(adminRepository: adminRepository),
        ),
        BlocProvider<TeamsCubit>(
          create: (context) => TeamsCubit(adminRepository: adminRepository),
        ),
        BlocProvider<CriteriaCubit>(
          create: (context) => CriteriaCubit(adminRepository: adminRepository),
        ),
        BlocProvider<JudgesCubit>(
          create: (context) => JudgesCubit(adminRepository: adminRepository),
        ),
        BlocProvider<JudgeDashboardCubit>(
          create: (context) => JudgeDashboardCubit(judgeRepository: judgeRepository),
        ),
        BlocProvider<JudgingCubit>(
          create: (context) => JudgingCubit(judgeRepository: judgeRepository),
        ),
        BlocProvider<ResultsDashboardCubit>(
          create: (context) => ResultsDashboardCubit(resultsRepository: resultsRepository),
        ),
        BlocProvider<TeamResultCubit>(
          create: (context) => TeamResultCubit(resultsRepository: resultsRepository),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
              RouteNames.login,
              (route) => false,
            );
          }
        },
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          title: 'IdeaX Judging System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: RouteNames.splash,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    ),
  );
}
}
