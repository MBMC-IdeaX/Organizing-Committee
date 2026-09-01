import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.user.role == UserRole.admin) {
            Navigator.pushReplacementNamed(context, RouteNames.adminDashboard);
          } else {
            Navigator.pushReplacementNamed(context, RouteNames.judgeDashboard);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundMeshGradient,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: AppDimensions.screenPadding,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AuthHeader(logoHeight: 52),
                        const SizedBox(height: AppDimensions.space32),

                        // Light Glassmorphism Login Card
                        GlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign In',
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: AppColors.primaryNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space4),
                                Text(
                                  'Enter your event credentials to continue',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: AppDimensions.space24),

                                // Error Banner if AuthError
                                if (state is AuthError) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppDimensions.space12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorBackground,
                                      borderRadius: AppDimensions.borderRadiusSmall,
                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                        const SizedBox(width: AppDimensions.space8),
                                        Expanded(
                                          child: Text(
                                            state.message,
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space16),
                                ],

                                // Username Input
                                AppTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  hintText: 'e.g. admin or judge_01',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: Validators.validateUsername,
                                  readOnly: isLoading,
                                ),
                                const SizedBox(height: AppDimensions.space16),

                                // Password Input
                                AppTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  isPassword: true,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: Validators.validatePassword,
                                  onSubmitted: (_) => _onLoginPressed(),
                                  readOnly: isLoading,
                                ),
                                const SizedBox(height: AppDimensions.space24),

                                // Submit Action Button
                                PrimaryButton(
                                  text: 'Sign In to IdeaX',
                                  onPressed: _onLoginPressed,
                                  isLoading: isLoading,
                                  icon: Icons.login_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space24),

                        // System info footer
                        Text(
                          'IdeaX Live Judging • Powered by Deepmind Systems',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
