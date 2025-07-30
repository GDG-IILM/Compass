import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  Timer? _tokenRefreshTimer;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoggedIn => isAuthenticated;

  // Authentication methods
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? studentId,
    String? department,
    String? year,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Validate inputs
      if (!_isValidEmail(email)) {
        throw AuthException('Please enter a valid email address');
      }

      if (!_isValidPassword(password)) {
        throw AuthException(
            'Password must be at least 8 characters long and contain uppercase, lowercase, and numbers'
        );
      }

      // Check if user already exists (simulate)
      if (email.toLowerCase() == 'test@example.com') {
        throw AuthException('An account with this email already exists');
      }

      // Create new user
      final user = UserModel(
        id: _generateUserId(),
        email: email.toLowerCase(),
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        studentId: studentId,
        department: department,
        year: year,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: false,
        role: UserRole.student,
      );

      // Save user data (simulate)
      await _saveUserToStorage(user);

      _currentUser = user;
      _startTokenRefreshTimer();
      notifyListeners();

      return AuthResult.success('Account created successfully! Please verify your email.');

    } on AuthException {
      rethrow;
    } catch (e) {
      _setError('Failed to create account. Please try again.');
      throw AuthException(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate inputs
      if (!_isValidEmail(email)) {
        throw AuthException('Please enter a valid email address');
      }

      if (password.isEmpty) {
        throw AuthException('Please enter your password');
      }

      // Simulate authentication
      UserModel? user = await _authenticateUser(email, password);

      if (user == null) {
        throw AuthException('Invalid email or password');
      }

      _currentUser = user;
      _startTokenRefreshTimer();
      notifyListeners();

      return AuthResult.success('Welcome back, ${user.firstName}!');

    } on AuthException {
      rethrow;
    } catch (e) {
      _setError('Failed to sign in. Please try again.');
      throw AuthException(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _tokenRefreshTimer?.cancel();
      await _clearUserFromStorage();

      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> resetPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isValidEmail(email)) {
        throw AuthException('Please enter a valid email address');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate sending reset email
      return AuthResult.success('Password reset email sent! Check your inbox.');

    } on AuthException {
      rethrow;
    } catch (e) {
      _setError('Failed to send reset email. Please try again.');
      throw AuthException(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        throw AuthException('You must be logged in to change password');
      }

      if (!_isValidPassword(newPassword)) {
        throw AuthException(
            'Password must be at least 8 characters long and contain uppercase, lowercase, and numbers'
        );
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return AuthResult.success('Password changed successfully!');

    } on AuthException {
      rethrow;
    } catch (e) {
      _setError('Failed to change password. Please try again.');
      throw AuthException(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> verifyEmail({required String verificationCode}) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        throw AuthException('No user logged in');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Update user verification status
      _currentUser = _currentUser!.copyWith(
        isEmailVerified: true,
        updatedAt: DateTime.now(),
      );

      await _saveUserToStorage(_currentUser!);
      notifyListeners();

      return AuthResult.success('Email verified successfully!');

    } on AuthException {
      rethrow;
    } catch (e) {
      _setError('Failed to verify email. Please try again.');
      throw AuthException(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? department,
    String? year,
    String? bio,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        throw AuthException('No user logged in');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        department: department,
        year: year,
        bio: bio,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _saveUserToStorage(_currentUser!);
      notifyListeners();

      return AuthResult.success('Profile updated successfully!');

    } on AuthException {
      rethrow;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      throw AuthException(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      // Try to load user from storage
      _currentUser = await _loadUserFromStorage();

      if (_currentUser != null) {
        _startTokenRefreshTimer();
      }
    } catch (e) {
      debugPrint('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email);
        }

  bool _isValidPassword(String password) {
    // At least 8 characters, contains uppercase, lowercase, and numbers
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<UserModel?> _authenticateUser(String email, String password) async {
    // Simulate different users for testing
    if (email.toLowerCase() == 'student@example.com' && password == 'Password123') {
      return UserModel(
        id: 'user_student_001',
        email: email.toLowerCase(),
        firstName: 'John',
        lastName: 'Doe',
        studentId: 'ST2024001',
        department: 'Computer Science',
        year: '3rd Year',
        section: 'A',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        isEmailVerified: true,
        role: UserRole.student,
        bio: 'Computer Science student passionate about mobile development',
        interests: ['Programming', 'Mobile Development', 'AI/ML'],
      );
    }

    if (email.toLowerCase() == 'faculty@example.com' && password == 'Password123') {
      return UserModel(
        id: 'user_faculty_001',
        email: email.toLowerCase(),
        firstName: 'Dr. Sarah',
        lastName: 'Johnson',
        department: 'Computer Science',
        createdAt: DateTime.now().subtract(const Duration(days: 1000)),
        updatedAt: DateTime.now(),
        isEmailVerified: true,
        role: UserRole.faculty,
        bio: 'Professor of Computer Science with expertise in Software Engineering',
      );
    }

    if (email.toLowerCase() == 'admin@example.com' && password == 'Password123') {
      return UserModel(
        id: 'user_admin_001',
        email: email.toLowerCase(),
        firstName: 'Admin',
        lastName: 'User',
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
        updatedAt: DateTime.now(),
        isEmailVerified: true,
        role: UserRole.admin,
      );
    }

    return null; // Invalid credentials
  }

  Future<void> _saveUserToStorage(UserModel user) async {
    // In a real app, this would save to secure storage or SharedPreferences
    // For now, we'll just simulate the operation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<UserModel?> _loadUserFromStorage() async {
    // In a real app, this would load from secure storage
    // For demo purposes, return null (no stored user)
    await Future.delayed(const Duration(milliseconds: 100));
    return null;
  }

  Future<void> _clearUserFromStorage() async {
    // In a real app, this would clear from secure storage
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    // Refresh token every 55 minutes (assuming 1-hour expiry)
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 55),
          (timer) => _refreshToken(),
    );
  }

  Future<void> _refreshToken() async {
    try {
      // In a real app, this would refresh the authentication token
      await Future.delayed(const Duration(milliseconds: 500));

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      // Optionally sign out user if token refresh fails
    }
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }
}

// Result classes
class AuthResult {
  final bool isSuccess;
  final String message;
  final String? errorCode;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.errorCode,
  });

  factory AuthResult.success(String message) {
    return AuthResult._(isSuccess: true, message: message);
  }

  factory AuthResult.failure(String message, [String? errorCode]) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

class AuthException implements Exception {
  final String message;
  final String? errorCode;

  AuthException(this.message, [this.errorCode]);

  @override
  String toString() => 'AuthException: $message';
}