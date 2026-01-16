import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';

abstract class CommunityDatasource {
  Future<List<CommunityModel>> getAllCommunities();
  Future<void> joinCommunity(String communityId, String userId);
  Future<void> leaveCommunity(String communityId, String userId);
}

class SupabaseCommunityDatasource implements CommunityDatasource {
  @override
  Future<List<CommunityModel>> getAllCommunities() async {
    try {
      final response = await SupabaseService.client
          .from('community')
          .select()
          .order('name', ascending: true);
      return (response as List)
          .map((json) => CommunityModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching communities', e);
      return [];
    }
  }

  @override
  Future<void> joinCommunity(String communityId, String userId) async {
    // Implementation depends on schema (many-to-many table?)
    // Placeholder
  }

  @override
  Future<void> leaveCommunity(String communityId, String userId) async {
    // Placeholder
  }
}
