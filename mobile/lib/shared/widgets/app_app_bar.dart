import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final bool automaticallyImplyLeading;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showLogo = false,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      centerTitle: true,
      title: showLogo
          ? Image.asset(
              'assets/images/ideax_logo.png',
              height: AppDimensions.logoHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                'IdeaX',
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryNavy),
              ),
            )
          : titleWidget ??
              (title != null
                  ? Text(
                      title!,
                      style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryNavy),
                    )
                  : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}
