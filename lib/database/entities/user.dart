class User {
  int? id;
  final String name;
  final int enabled;
  final String username;
  final String password;
  final String role;
  User({
    this.id,
    required this.name,
    required this.enabled,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  // get class object from map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      enabled: map['enabled'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
    );
  }
}
