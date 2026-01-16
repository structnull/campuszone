/// Centralized UI strings and error messages
///
/// Usage:
/// ```dart
/// Text(AppStrings.welcomeBack)
/// ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.loginFailed)));
/// ```
abstract class AppStrings {
  // ============================================
  // APP
  // ============================================

  /// App name
  static const String appName = 'CampusZone';

  // ============================================
  // AUTH
  // ============================================

  /// Welcome message
  static const String welcomeBack = 'Welcome Back :)';

  /// Sign in subtitle
  static const String signInToContinue = 'Please Sign in to continue';

  /// Email/College ID label
  static const String emailOrCollegeId = 'Email or College ID';

  /// Password label
  static const String password = 'Password';

  /// Forgot password link
  static const String forgotPassword = 'Forgot Password?';

  /// Sign in button
  static const String signIn = 'Sign In';

  /// Sign up button
  static const String signUp = 'Sign Up';

  /// Don't have account text
  static const String dontHaveAccount = "Don't have an account?";

  /// Register title
  static const String registerTitle = 'Register as a new user!';

  /// Register subtitle
  static const String registerSubtitle =
      'Please fill in the details to continue';

  /// Email label
  static const String email = 'Email';

  /// College ID label
  static const String collegeId = 'College ID';

  /// Register button
  static const String register = 'Register';

  /// Reset password button
  static const String resetPassword = 'Reset Password';

  // ============================================
  // VALIDATION ERRORS
  // ============================================

  /// Required field error
  static const String required = 'Required';

  /// Enter email error
  static const String enterEmail = 'Please enter your email';

  /// Invalid email error
  static const String invalidEmail = 'Enter a valid email';

  /// Enter college ID error
  static const String enterCollegeId = 'Please enter your College ID';

  /// Password length error
  static const String passwordTooShort =
      'Password must be at least 8 characters';

  /// Password uppercase error
  static const String passwordNeedsUppercase =
      'Include at least one uppercase letter';

  /// Password lowercase error
  static const String passwordNeedsLowercase =
      'Include at least one lowercase letter';

  /// Password number error
  static const String passwordNeedsNumber = 'Include at least one number';

  /// Name required error
  static const String nameRequired = 'Name is required to register';

  // ============================================
  // AUTH MESSAGES
  // ============================================

  /// Login failed message
  static const String loginFailed = 'Login failed. Please try again.';

  /// No college ID found message
  static const String noCollegeIdFound = 'No matching College ID found.';

  /// Registration successful message
  static const String registrationSuccessful = 'Registration successful!';

  /// Registration failed message
  static const String registrationFailed = 'Registration failed.';

  /// Password reset email sent message
  static const String passwordResetSent =
      'A password reset email has been sent to the provided email address. Please check your inbox.';

  // ============================================
  // CONNECTIVITY
  // ============================================

  /// No internet message
  static const String noInternet = 'No internet connection';

  // ============================================
  // SECTIONS / NAVIGATION
  // ============================================

  /// Home tab
  static const String home = 'Home';

  /// Community tab
  static const String community = 'Community';

  /// Resources tab
  static const String resources = 'Resources';

  /// Profile tab
  static const String profile = 'Profile';

  /// Chat section
  static const String chat = 'Chat';

  // ============================================
  // RESOURCES
  // ============================================

  /// Lost and Found title
  static const String lostAndFound = 'Lost and Found';

  /// Lost and Found section
  static const String lostAndFoundSection = 'Lost and Found Section';

  /// Notes title
  static const String notes = 'Notes';

  /// Notes section
  static const String notesSection = 'Notes Section';

  /// Useful links title
  static const String usefulLinks = 'Useful Links';

  /// Error loading links
  static const String errorLoadingLinks = 'Error loading links';

  /// No links found
  static const String noLinksFound = 'No links found';

  // ============================================
  // COMMON ACTIONS
  // ============================================

  /// Cancel button
  static const String cancel = 'Cancel';

  /// OK button
  static const String ok = 'OK';

  /// Delete button
  static const String delete = 'Delete';

  /// Comments button
  static const String comments = 'Comments';

  /// Error title
  static const String error = 'Error';

  /// Confirm delete title
  static const String confirmDelete = 'Confirm Delete';

  /// Delete post confirmation
  static const String deletePostConfirmation =
      'Are you sure you want to delete this post?';

  /// Delete note confirmation
  static const String deleteNoteConfirmation =
      'Are you sure you want to delete this note?';

  /// Delete comment confirmation
  static const String deleteCommentConfirmation =
      'Are you sure you want to delete this comment? This action cannot be undone.';

  /// Post deleted message
  static const String postDeleted = 'Post deleted successfully.';

  /// Note deleted message
  static const String noteDeleted = 'Note deleted successfully.';

  /// Deleting message
  static const String deleting = 'Deleting...';

  /// Delete error message
  static const String deleteError = 'Error deleting. Please try again.';

  // ============================================
  // EMPTY STATES
  // ============================================

  /// No posts found
  static const String noPostsFound = 'No posts found';

  /// Be first to post
  static const String beFirstToPost =
      'Be the first to post a lost or found item!';

  /// No notes found
  static const String noNotesFound = 'No notes found';

  /// Be first to upload
  static const String beFirstToUpload = 'Be the first to upload a note!';

  // ============================================
  // PROFILE
  // ============================================

  /// Edit profile
  static const String editProfile = 'Edit Profile';

  /// Profile updated
  static const String profileUpdated = 'Profile updated successfully!';

  /// Profile picture updated
  static const String profilePictureUpdated =
      'Profile picture updated successfully.';

  /// Logout
  static const String logout = 'Logout';

  /// Guest user
  static const String guest = 'Guest';

  /// Default user
  static const String user = 'User';

  /// Unknown user
  static const String unknownUser = 'Unknown User';

  // ============================================
  // GENERIC ERROR
  // ============================================

  /// Something went wrong
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';

  /// Failed to load
  static const String failedToLoad = 'Failed to load. Please try again.';

  /// Could not launch URL
  static const String couldNotLaunchUrl = 'Could not launch URL';
}
