class UserModel {
  const UserModel({
    required this.id,
    required this.firstname,
    required this.middlename,
    required this.surname,
    required this.email,
  });

  final int id;
  final String firstname;
  final String middlename;
  final String surname;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse('${json['id'] ?? ''}') ?? 0,
      firstname: (json['firstname'] ?? '').toString(),
      middlename: (json['middlename'] ?? '').toString(),
      surname: (json['surname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}
