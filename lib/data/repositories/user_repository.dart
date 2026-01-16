import 'package:campuszone/data/datasources/datasources.dart';
import 'package:campuszone/data/models/models.dart';

class UserRepository {
  final UserDatasource _datasource;

  UserRepository({UserDatasource? datasource})
      : _datasource = datasource ?? SupabaseUserDatasource();

  Future<UserModel?> getUserById(String id) => _datasource.getUserById(id);
  Future<UserModel?> getUserByCollegeId(String collegeId) =>
      _datasource.getUserByCollegeId(collegeId);
  Future<List<UserModel>> getAllUsers() => _datasource.getAllUsers();
  Future<void> updateUser(UserModel user) => _datasource.updateUser(user);
  Future<void> updateSocials(String userId, SocialsModel socials) =>
      _datasource.updateSocials(userId, socials);
}
