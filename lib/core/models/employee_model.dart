class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.firstname,
    required this.middlename,
    required this.surname,
  });

  final int id;
  final String firstname;
  final String middlename;
  final String surname;

  String get fullName {
    return [firstname, middlename, surname]
        .where((v) => v.trim().isNotEmpty)
        .join(' ')
        .trim();
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: int.tryParse('${json['id'] ?? ''}') ?? 0,
      firstname: (json['firstname'] ?? '').toString(),
      middlename: (json['middlename'] ?? '').toString(),
      surname: (json['surname'] ?? '').toString(),
    );
  }
}
