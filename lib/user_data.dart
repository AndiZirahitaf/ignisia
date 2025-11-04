// lib/user_data.dart
import 'dart:convert';

/// Simple immutable user model containing profile picture, name, email and password.
class UserData {
  /// URL or local path to profile picture (can be null if not set).
  final String? profilePicture;

  /// Full name of the user.
  final String name;

  /// Email address.
  final String email;

  /// Password (store hashed in production).
  final String password;

  const UserData({
    this.profilePicture,
    required this.name,
    required this.email,
    required this.password,
  });

  /// Example static user data for development / testing.
  static const List<UserData> sampleUsers = [
    UserData(
      profilePicture: 'https://example.com/avatars/alice.png',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      password: 'password123',
    ),
    UserData(
      profilePicture: null,
      name: 'Bob Smith',
      email: 'bob@example.com',
      password: 'secret',
    ),
    UserData(
      profilePicture: 'assets/images/user_carol.png',
      name: 'Carol Lee',
      email: 'carol@example.com',
      password: 'hunter2',
    ),
  ];
}
