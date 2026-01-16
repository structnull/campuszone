import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;

  final Color? textColor;
  final IconThemeData? iconTheme;

  const AppAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.textColor,
    this.iconTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(title!,
              style: AppTextStyles.titleLarge
                  .copyWith(color: textColor ?? AppColors.textPrimary))
          : null,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: showBackButton,
      elevation: AppElevation.none,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      iconTheme: iconTheme ?? IconThemeData(color: AppColors.primary),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppTransparentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<Widget>? actions;

  const AppTransparentAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: AppElevation.none,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.primary),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
