// lib/models/user.dart
class User {
  final String username;
  final String email;
  final String name;

  User({required this.username, required this.email, required this.name});

  // Match your Go JSON structure
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      name: json['name'],
    );
  }
}
