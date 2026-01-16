import 'package:campuszone/presentation/layout/layout.dart';
import 'package:campuszone/presentation/screens/community/community.dart';
import 'package:campuszone/presentation/screens/home/home.dart';
import 'package:campuszone/presentation/screens/profile/profile.dart';
import 'package:campuszone/presentation/screens/resources/resources.dart';
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      pages: const [
        HomePage(),
        CommunityPage(),
        ResourcesPage(),
        ProfilePage(),
      ],
    );
  }
}
