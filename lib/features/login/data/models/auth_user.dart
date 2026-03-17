class AuthUser {
  final int id;
  final String username;
  final String firstname;
  final String middlename;
  final String surname;
  final String phonenum;
  final String address;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.username,
    required this.firstname,
    required this.middlename,
    required this.surname,
    required this.phonenum,
    required this.address,
    required this.email,
    required this.role,
  });

  String get fullName {
    final parts = <String>[firstname, middlename, surname]
        .where((value) => value.trim().isNotEmpty)
        .map((value) => value.trim())
        .toList();
    return parts.isEmpty ? username : parts.join(' ');
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: int.tryParse((json['id'] ?? '').toString()) ?? 0,
      username: (json['username'] ?? '').toString(),
      firstname: (json['firstname'] ?? '').toString(),
      middlename: (json['middlename'] ?? '').toString(),
      surname: (json['surname'] ?? '').toString(),
      phonenum: (json['phonenum'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}
