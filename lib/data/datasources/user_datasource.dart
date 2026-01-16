import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';

abstract class UserDatasource {
  Future<UserModel?> getUserById(String id);
  Future<UserModel?> getUserByCollegeId(String collegeId);
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUser(UserModel user);
  Future<void> updateSocials(String userId, SocialsModel socials);
}

class SupabaseUserDatasource implements UserDatasource {
  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await SupabaseService.usersTable
          .select('*, socials(*)')
          .eq('id', id)
          .maybeSingle();
      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Error fetching user by id', e);
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByCollegeId(String collegeId) async {
    try {
      final response = await SupabaseService.usersTable
          .select()
          .eq('collegeid', collegeId.toUpperCase())
          .maybeSingle();
      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Error fetching user by college id', e);
      return null;
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUserId = SupabaseService.currentUserId;
      final response = await SupabaseService.usersTable
          .select()
          .neq('id', currentUserId ?? '');
      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching all users', e);
      return [];
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await SupabaseService.usersTable.update(user.toJson()).eq('id', user.id);
    } catch (e) {
      AppLogger.error('Error updating user', e);
      rethrow;
    }
  }

  @override
  Future<void> updateSocials(String userId, SocialsModel socials) async {
    try {
      await SupabaseService.client
          .from('socials')
          .upsert({'user_id': userId, ...socials.toJson()});
    } catch (e) {
      AppLogger.error('Error updating socials', e);
      rethrow;
    }
  }
}
