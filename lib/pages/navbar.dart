import 'package:animations/animations.dart';
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
    ProfilePage(),
  ];

  // Constants for colors
  static const Color _transparentWhite = Color.fromARGB(0, 255, 255, 255);
  static const Color _semiTransparentWhite = Color.fromARGB(128, 255, 255, 255);
  static const Color _moreOpaqueWhite = Color.fromARGB(204, 255, 255, 255);
  static const Color _fullyWhite = Colors.white;

  // Constants for GNav properties
  static const Color _unselectedColor = Colors.black;
  static const Color _selectedColor = Colors.white;
  static const Color _tabBackgroundColor = Colors.black;
  static const double _iconSize = 36.0;
  static const EdgeInsets _tabPadding = EdgeInsets.all(14.0);
  static const EdgeInsets _navBarPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 30);

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
      duration: const Duration(milliseconds: 500),
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
        height: 150, // Adjust this height as needed
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _transparentWhite, // Almost fully transparent
              _semiTransparentWhite, // Semi-transparent white
              _moreOpaqueWhite, // More opaque white
              _fullyWhite, // Fully white at the bottom
            ],
            stops: [
              0.0,
              0.3,
              0.8,
              1.0
            ], // Move the stop for transparency further along
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
        padding: _navBarPadding,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: GNav(
            backgroundColor: Colors.transparent, // Keep it transparent
            color: _unselectedColor, // Unselected icon color
            activeColor: _selectedColor, // Selected icon color
            tabBackgroundColor:
                _tabBackgroundColor, // The tab color "pill shaped thingy"
            gap: 8,
            iconSize: _iconSize, // Tab button icon size
            padding: _tabPadding,
            haptic: true, // Haptic feedback
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: LineIcons.home,
                text: 'Home',
              ),
              GButton(
                icon: LineIcons.users,
                text: 'Community',
              ),
              GButton(
                icon: LineIcons.book,
                text: 'Resources',
              ),
              GButton(
                icon: LineIcons.user,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
