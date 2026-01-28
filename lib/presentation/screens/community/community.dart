import 'package:campuszone/core/core.dart';
import 'package:campuszone/core/config/env.dart';
import 'package:campuszone/presentation/screens/community/events/events.dart';
import 'package:campuszone/presentation/widgets/common/squiggly_divider.dart';
import 'package:campuszone/presentation/screens/community/communityspace/community_space.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String get _clgname => Env.clgName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  color: AppColors.cardBackground,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(AppStrings.community,
                        style: AppTextStyles.displayLarge
                            .copyWith(color: AppColors.textPrimary)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: AppSpacing.sectionLarge, bottom: AppSpacing.lg),
                child: Text(AppStrings.popularCommunities,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 400, child: CommunitySpace()),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: SquigglyDivider(
                    height: 50, width: 200, color: AppColors.primary),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('${AppStrings.eventsAt}\n$_clgname',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
                child: SizedBox(width: double.infinity, child: EventPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
