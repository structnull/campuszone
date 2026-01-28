import 'package:campuszone/data/datasources/datasources.dart';
import 'package:campuszone/data/models/models.dart';

class CommunityRepository {
  final CommunityDatasource _datasource;

  CommunityRepository({CommunityDatasource? datasource})
      : _datasource = datasource ?? SupabaseCommunityDatasource();

  Future<List<CommunityModel>> getAllCommunities() =>
      _datasource.getAllCommunities();
}
