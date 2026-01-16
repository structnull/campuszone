import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseService {
  static bool _initialized = false;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
  static SupabaseStorageClient get storage => client.storage;

  // Storage buckets
  static StorageFileApi bucket(String name) => storage.from(name);
  static StorageFileApi get profilePicBucket => bucket('profilepic');
  static StorageFileApi get notesBucket => bucket('notes');
  static StorageFileApi get lostAndFoundBucket => bucket('lostandfound');

  // Auth
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth
        .signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Database tables
  static SupabaseQueryBuilder from(String table) => client.from(table);
  static SupabaseQueryBuilder get usersTable => from('users');
  static SupabaseQueryBuilder get notesTable => from('notes');
  static SupabaseQueryBuilder get lostAndFoundTable => from('lostandfound');
  static SupabaseQueryBuilder get communitiesTable => from('communities');
  static SupabaseQueryBuilder get eventsTable => from('events');
  static SupabaseQueryBuilder get messagesTable => from('messages');
  static SupabaseQueryBuilder get socialsTable => from('socials');
  static SupabaseQueryBuilder get usefulLinksTable => from('usefullinks');
  static SupabaseQueryBuilder get notesCommentsTable => from('notes_comments');
  static SupabaseQueryBuilder get lostAndFoundCommentsTable =>
      from('lostandfound_comments');

  // Storage helpers
  static String getPublicUrl(String bucket, String path) {
    return storage.from(bucket).getPublicUrl(path);
  }

  static String getProfilePictureUrl(String userId, {String? cacheBuster}) {
    var url = profilePicBucket.getPublicUrl('$userId/profile_picture.jpg');
    if (cacheBuster != null && cacheBuster.isNotEmpty) {
      url = '$url?t=$cacheBuster';
    }
    return url;
  }
}
