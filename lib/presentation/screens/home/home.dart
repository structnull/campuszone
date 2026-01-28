import 'package:campuszone/presentation/screens/chat/chat_list.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/presentation/widgets/common/squiggly_divider.dart';
import 'package:campuszone/presentation/screens/home/notice_board.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userId;
  bool isLoading = true;
  bool isHovering = false;
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<void> fetchUserName() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          userName = AppStrings.guest;
          isLoading = false;
        });
      }
      return;
    }
    userId = user.id;
    try {
      final response = await SupabaseService.usersTable
          .select('name')
          .eq('id', user.id)
          .single();
      if (!mounted) return;
      setState(() {
        userName = response['name'] ?? AppStrings.user;
        isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Fetch user name failed', e);
      if (!mounted) return;
      setState(() {
        userName = AppStrings.user;
        isLoading = false;
      });
    }
  }

  Future<void> initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    ConnectivityResult connectivityResult =
        result.isNotEmpty ? result.first : ConnectivityResult.none;
    updateConnectionStatus(connectivityResult);
  }

  void updateConnectionStatus(ConnectivityResult result) {
    if (mounted) {
      setState(() {
        isOnline = result != ConnectivityResult.none;
      });
      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppStrings.noInternet),
              duration: AppAnimations.snackbarDuration),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
    initConnectivity();
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

  double _calculateNameFontSize(BuildContext context, String name) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenWidth < 600 ? 40.0 : 50.0;
    if (name.length > 12) return baseFontSize * 0.8;
    if (name.length > 8) return baseFontSize * 0.9;
    return baseFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final double horizontalPadding =
        isSmallScreen ? AppSpacing.lg : screenSize.width * 0.1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical:
                          isSmallScreen ? AppSpacing.xxl : AppSpacing.huge),
                  margin: EdgeInsets.only(top: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.inputRadius,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: .05),
                          offset: Offset(0, 2),
                          blurRadius: 4),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: AppColors.shimmerBase,
                                highlightColor: AppColors.shimmerHighlight,
                                child: CircleAvatar(
                                  radius: isSmallScreen
                                      ? AppDimensions.avatarRadiusSmall
                                      : AppDimensions.avatarRadiusLarge,
                                  backgroundColor: AppColors.shimmerBase,
                                ),
                              ),
                              SizedBox(width: AppSpacing.lg),
                              Container(
                                  width: isSmallScreen ? 150 : 200,
                                  height: 20,
                                  color: AppColors.shimmerBase),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ValueListenableBuilder(
                                valueListenable: globals.globalCacheBuster,
                                builder: (context, value, child) {
                                  final cacheBuster = value ?? "";
                                  String imageUrl = "";
                                  if (userId != null) {
                                    imageUrl =
                                        SupabaseService.getProfilePictureUrl(
                                            userId!,
                                            cacheBuster: cacheBuster);
                                  }
                                  final avatarSize =
                                      isSmallScreen ? 60.0 : 80.0;
                                  return CircleAvatar(
                                    radius: isSmallScreen
                                        ? AppDimensions.avatarRadiusSmall
                                        : AppDimensions.avatarRadiusLarge,
                                    backgroundColor: AppColors.shimmerBase,
                                    child: imageUrl.isEmpty
                                        ? ClipOval(
                                            child: Image.asset(
                                                AppAssets.profileDefault,
                                                fit: BoxFit.cover,
                                                width: avatarSize,
                                                height: avatarSize))
                                        : ClipOval(
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              width: avatarSize,
                                              height: avatarSize,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      AppColors.shimmerBase,
                                                  highlightColor: AppColors
                                                      .shimmerHighlight,
                                                  child: Container(
                                                      width: avatarSize,
                                                      height: avatarSize,
                                                      color: AppColors
                                                          .shimmerBase),
                                                );
                                              },
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                      AppAssets.profileDefault,
                                                      fit: BoxFit.cover,
                                                      width: avatarSize,
                                                      height: avatarSize),
                                            ),
                                          ),
                                  );
                                },
                              ),
                              SizedBox(width: AppSpacing.lg),
                              Flexible(
                                child: Text(
                                  'Hey ${userName ?? AppStrings.user}!',
                                  style: AppTextStyles.displayMedium.copyWith(
                                    fontSize: _calculateNameFontSize(
                                        context, userName ?? AppStrings.user),
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: AppSpacing.section),
                StatefulBuilder(builder: (context, setStateSB) {
                  return GestureDetector(
                    onTapDown: (_) => setStateSB(() => isHovering = true),
                    onTapUp: (_) => setStateSB(() => isHovering = false),
                    onTapCancel: () => setStateSB(() => isHovering = false),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChatPageList())),
                    child: AnimatedContainer(
                      duration: AppAnimations.fast,
                      transform: isHovering
                          ? Matrix4.translationValues(
                              0, AppAnimations.hoverLift, 0)
                          : Matrix4.identity(),
                      width: double.infinity,
                      height: isSmallScreen
                          ? AppDimensions.chatCardHeightSmall
                          : AppDimensions.chatCardHeightLarge,
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: AppRadius.buttonRadius,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardDark
                                .withValues(alpha: isHovering ? 0.3 : 0.2),
                            blurRadius: isHovering ? 16 : 12,
                            offset: isHovering ? Offset(0, 8) : Offset(0, 6),
                            spreadRadius: isHovering ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(AppStrings.chat,
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.textWhite,
                                  fontSize: isSmallScreen ? 42 : 52,
                                )),
                          ),
                          Positioned(
                            right: AppSpacing.lg,
                            bottom: AppSpacing.lg,
                            child: Icon(Icons.arrow_forward_rounded,
                                color:
                                    AppColors.textWhite.withValues(alpha: .7),
                                size: isSmallScreen
                                    ? AppIconSize.df
                                    : AppIconSize.lg),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: AppSpacing.xxl),
                Center(
                    child: SquigglyDivider(
                        width: 200, height: 40, color: AppColors.primary)),
                SizedBox(height: AppSpacing.xxl),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonRadius),
                  elevation: AppElevation.feature,
                  color: AppColors.primaryDark,
                  child: SizedBox(
                      height: AppDimensions.noticeboardHeight,
                      child: const NoticeBoardContent()),
                ),
                SizedBox(height: AppSpacing.xxl),
                Center(
                    child: SquigglyDivider(
                        width: 200, height: 50, color: AppColors.primary)),
                SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
