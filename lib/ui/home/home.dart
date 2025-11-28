import 'package:campuszone/chat/chat_list.dart';
import 'package:campuszone/custom/custom_divider.dart';
import 'package:campuszone/ui/home/notice_board.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:campuszone/globals.dart'; // for globalCacheBuster

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  String? userName;
  String? userId;
  bool isLoading = true;
  bool isHovering = false;
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<void> fetchUserName() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          userName = 'Guest';
          isLoading = false;
        });
      }
      return;
    }
    // Store user id for profile picture URL construction.
    userId = user.id;
    try {
      final response = await supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .single();
      if (!mounted) return;
      setState(() {
        userName = response['name'] ?? 'User';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        userName = 'User';
        isLoading = false;
      });
    }
  }

  // Initialize connectivity monitoring
  Future<void> initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    ConnectivityResult connectivityResult =
        result.isNotEmpty ? result.first : ConnectivityResult.none;
    updateConnectionStatus(connectivityResult);
  }

  // Update connection status based on connectivity result
  void updateConnectionStatus(ConnectivityResult result) {
    if (mounted) {
      setState(() {
        isOnline = result != ConnectivityResult.none;
      });
      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
    initConnectivity();

    // Listen for connectivity changes without extra type casts
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        updateConnectionStatus(results.first);
      } else {
        updateConnectionStatus(ConnectivityResult.none);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Calculate responsive font size for the greeting
  double _calculateNameFontSize(BuildContext context, String name) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenWidth < 600 ? 40.0 : 50.0;
    if (name.length > 12) {
      return baseFontSize * 0.8;
    } else if (name.length > 8) {
      return baseFontSize * 0.9;
    }
    return baseFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final double horizontalPadding =
        isSmallScreen ? 16.0 : screenSize.width * 0.1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Greeting Container with Profile Pic and Username
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 24.0 : 32.0,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: CircleAvatar(
                                  radius: isSmallScreen ? 30 : 40,
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: isSmallScreen ? 150 : 200,
                                height: 20,
                                color: Colors.grey[300],
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Picture Avatar using similar logic to ProfilePage
                              ValueListenableBuilder(
                                valueListenable: globalCacheBuster,
                                builder: (context, value, child) {
                                  final cacheBuster = value ?? "";
                                  String imageUrl = "";
                                  if (userId != null) {
                                    imageUrl = supabase.storage
                                        .from('profilepic')
                                        .getPublicUrl(
                                            '$userId/profile_picture.jpg');
                                    if (cacheBuster.isNotEmpty) {
                                      imageUrl = '$imageUrl?t=$cacheBuster';
                                    }
                                  }
                                  return CircleAvatar(
                                    radius: isSmallScreen ? 30 : 40,
                                    backgroundColor: Colors.grey[300],
                                    child: imageUrl.isEmpty
                                        ? ClipOval(
                                            child: Image.asset(
                                              'assets/profile.png',
                                              fit: BoxFit.cover,
                                              width: isSmallScreen ? 60 : 80,
                                              height: isSmallScreen ? 60 : 80,
                                            ),
                                          )
                                        : ClipOval(
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              width: isSmallScreen ? 60 : 80,
                                              height: isSmallScreen ? 60 : 80,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    width:
                                                        isSmallScreen ? 60 : 80,
                                                    height:
                                                        isSmallScreen ? 60 : 80,
                                                    color: Colors.grey[300],
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/profile.png',
                                                  fit: BoxFit.cover,
                                                  width:
                                                      isSmallScreen ? 60 : 80,
                                                  height:
                                                      isSmallScreen ? 60 : 80,
                                                );
                                              },
                                            ),
                                          ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              // Greeting Text
                              Flexible(
                                child: Text(
                                  'Hey ${userName ?? 'User'}!',
                                  style: TextStyle(
                                    fontFamily: 'PlayfairDisplay',
                                    fontSize: _calculateNameFontSize(
                                        context, userName ?? 'User'),
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 48),
                // Chat Card Element (existing code)
                StatefulBuilder(builder: (context, setStateSB) {
                  return GestureDetector(
                    onTapDown: (_) => setStateSB(() => isHovering = true),
                    onTapUp: (_) => setStateSB(() => isHovering = false),
                    onTapCancel: () => setStateSB(() => isHovering = false),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatPageList(),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: isHovering
                          ? Matrix4.translationValues(0, -5, 0)
                          : Matrix4.identity(),
                      width: double.infinity,
                      height: isSmallScreen ? 150 : 180,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isHovering ? 0.3 : 0.2),
                            blurRadius: isHovering ? 16 : 12,
                            offset: isHovering
                                ? const Offset(0, 8)
                                : const Offset(0, 6),
                            spreadRadius: isHovering ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 42 : 52,
                                fontFamily: 'PlayfairDisplay',
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withValues(alpha: .7),
                              size: isSmallScreen ? 24 : 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Center(
                  child: SquigglyDivider(
                      width: 200, height: 40, color: Colors.black),
                ),
                const SizedBox(height: 24),
                // Noticeboard displayed as a Card Element
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  elevation: 24,
                  color: const Color(0xFF121212),
                  child: SizedBox(
                    height: 800, // adjust height as needed
                    child: const NoticeBoardContent(),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                    child: SquigglyDivider(
                  width: 200,
                  height: 50,
                  color: Colors.black,
                )),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
