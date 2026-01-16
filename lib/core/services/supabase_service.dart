import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase service wrapper
///
/// This replaces direct `Supabase.instance.client` calls throughout the app,
/// providing a single point of access to Supabase functionality.
///
/// Usage:
/// ```dart
/// // Access the client
/// final client = SupabaseService.client;
///
/// // Get current user
/// final user = SupabaseService.currentUser;
///
/// // Get storage
/// final storage = SupabaseService.storage;
/// ```
abstract class SupabaseService {
  static bool _initialized = false;

  /// Initialize Supabase with URL and anon key
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _initialized = true;
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Get the current user's ID
  static String? get currentUserId => currentUser?.id;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Get the storage client
  static SupabaseStorageClient get storage => client.storage;

  /// Get a storage bucket
  static StorageFileApi bucket(String name) => storage.from(name);

  /// Profile picture bucket
  static StorageFileApi get profilePicBucket => bucket('profilepic');

  /// Notes bucket
  static StorageFileApi get notesBucket => bucket('notes');

  /// Lost and found bucket
  static StorageFileApi get lostAndFoundBucket => bucket('lostandfound');

  // ============================================
  // AUTH METHODS
  // ============================================

  /// Sign in with email and password
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password for email
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // ============================================
  // DATABASE HELPER METHODS
  // ============================================

  /// Get a table reference
  static SupabaseQueryBuilder from(String table) => client.from(table);

  /// Users table
  static SupabaseQueryBuilder get usersTable => from('users');

  /// Notes table
  static SupabaseQueryBuilder get notesTable => from('notes');

  /// Lost and found table
  static SupabaseQueryBuilder get lostAndFoundTable => from('lostandfound');

  /// Communities table
  static SupabaseQueryBuilder get communitiesTable => from('communities');

  /// Events table
  static SupabaseQueryBuilder get eventsTable => from('events');

  /// Messages table
  static SupabaseQueryBuilder get messagesTable => from('messages');

  /// Socials table
  static SupabaseQueryBuilder get socialsTable => from('socials');

  /// Useful links table
  static SupabaseQueryBuilder get usefulLinksTable => from('usefullinks');

  /// Comments table for notes
  static SupabaseQueryBuilder get notesCommentsTable => from('notes_comments');

  /// Comments table for lost and found
  static SupabaseQueryBuilder get lostAndFoundCommentsTable =>
      from('lostandfound_comments');

  // ============================================
  // STORAGE HELPER METHODS
  // ============================================

  /// Get public URL for a file in a bucket
  static String getPublicUrl(String bucket, String path) {
    return storage.from(bucket).getPublicUrl(path);
  }

  /// Get profile picture URL with optional cache buster
  static String getProfilePictureUrl(String userId, {String? cacheBuster}) {
    var url = profilePicBucket.getPublicUrl('$userId/profile_picture.jpg');
    if (cacheBuster != null && cacheBuster.isNotEmpty) {
      url = '$url?t=$cacheBuster';
    }
    return url;
  }
}
