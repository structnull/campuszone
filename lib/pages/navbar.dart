import 'package:animations/animations.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/ui/community/community.dart';
import 'package:campuszone/ui/home/home.dart';
import 'package:campuszone/ui/profile/profile.dart';
import 'package:campuszone/ui/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    CommunityPage(),
    ResourcesPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildPageView(),
          _buildGradientBackground(),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageTransitionSwitcher(
      duration: AppAnimations.slow,
      transitionBuilder: (Widget child, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: _pages[_selectedIndex],
    );
  }

  Widget _buildGradientBackground() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: AppDimensions.gradientHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.transparentWhite,
              AppColors.semiTransparentWhite,
              AppColors.opaqueWhite,
              AppColors.textWhite
            ],
            stops: [0.0, 0.3, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: AppSpacing.navBarPadding,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
          child: GNav(
            backgroundColor: Colors.transparent,
            color: AppColors.navUnselected,
            activeColor: AppColors.navSelected,
            tabBackgroundColor: AppColors.tabBackground,
            gap: 8,
            iconSize: AppIconSize.xl,
            padding: AppSpacing.tabPadding,
            haptic: true,
            onTabChange: (index) => setState(() => _selectedIndex = index),
            tabs: [
              GButton(icon: LineIcons.home, text: AppStrings.home),
              GButton(icon: LineIcons.users, text: AppStrings.community),
              GButton(icon: LineIcons.book, text: AppStrings.resources),
              GButton(icon: LineIcons.user, text: AppStrings.profile),
            ],
          ),
        ),
      ),
    );
  }
}
