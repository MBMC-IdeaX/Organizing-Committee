import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay slightly to give a polished, smooth splash experience
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.read<AuthCubit>().restoreSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.user.role == UserRole.admin) {
            Navigator.pushReplacementNamed(context, RouteNames.adminDashboard);
          } else {
            Navigator.pushReplacementNamed(context, RouteNames.judgeDashboard);
          }
        } else if (state is Unauthenticated || state is AuthError) {
          Navigator.pushReplacementNamed(context, RouteNames.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundMeshGradient,
          ),
          child: Center(
            child: Padding(
              padding: AppDimensions.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Light Glassmorphism Brand Card
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/ideax_logo.png',
                          height: AppDimensions.splashLogoHeight,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            'IdeaX',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Text(
                          'IdeaX Judging System',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          'Hackathon Evaluation Platform',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'Initializing workspace...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
