import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersDbKey = 'users_database';
  final _uuid = const Uuid();

  // Simulated network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Sign up new user
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();

    // Check if user already exists
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersDbKey);
    Map<String, dynamic> usersDb = {};

    if (usersJson != null) {
      usersDb = json.decode(usersJson) as Map<String, dynamic>;

      // Check if email already exists
      for (var userData in usersDb.values) {
        if (userData['email'] == email) {
          throw Exception('Email already registered');
        }
      }
    }

    // Create new user
    final user = User(
      id: _uuid.v4(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    // Store user in simulated database
    usersDb[user.id] = {
      ...user.toJson(),
      'password': password, // In real app, this would be hashed
    };
    await prefs.setString(_usersDbKey, json.encode(usersDb));

    // Set as current user
    await prefs.setString(_userKey, json.encode(user.toJson()));

    return user;
  }

  // Sign in existing user
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersDbKey);

    if (usersJson == null) {
      throw Exception('Invalid email or password');
    }

    final usersDb = json.decode(usersJson) as Map<String, dynamic>;

    // Find user by email
    for (var userData in usersDb.values) {
      if (userData['email'] == email && userData['password'] == password) {
        final user = User.fromJson(userData as Map<String, dynamic>);

        // Set as current user
        await prefs.setString(_userKey, json.encode(user.toJson()));

        return user;
      }
    }

    throw Exception('Invalid email or password');
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        return null;
      }

      return User.fromJson(json.decode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Update user profile
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? avatarUrl,
    String? currentPassword,
  }) async {
    await _simulateNetworkDelay();

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersDbKey);

    if (usersJson == null) {
      throw Exception('User not found');
    }

    final usersDb = json.decode(usersJson) as Map<String, dynamic>;

    if (!usersDb.containsKey(userId)) {
      throw Exception('User not found');
    }

    final userData = usersDb[userId] as Map<String, dynamic>;
    final currentUser = User.fromJson(userData);

    // If email is changing, verify password
    if (email != null && email != currentUser.email) {
      if (currentPassword == null || currentPassword != userData['password']) {
        throw Exception('Current password verification failed');
      }
    }

    // Update user data
    final updatedUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      email: email ?? currentUser.email,
      avatarUrl: avatarUrl ?? currentUser.avatarUrl,
    );

    // Update in database
    usersDb[userId] = {
      ...updatedUser.toJson(),
      'password': userData['password'], // Keep password
    };
    await prefs.setString(_usersDbKey, json.encode(usersDb));

    // Update current user
    await prefs.setString(_userKey, json.encode(updatedUser.toJson()));

    return updatedUser;
  }
}
