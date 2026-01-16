import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: useSafeArea ? SafeArea(child: body) : body,
    );
  }
}

class AppScrollableScaffold extends StatelessWidget {
  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;

  const AppScrollableScaffold({
    super.key,
    required this.children,
    this.appBar,
    this.padding,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: content),
    );
  }
}
