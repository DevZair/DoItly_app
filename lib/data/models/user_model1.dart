class UserModel {
  const UserModel({
    required this.name,
    required this.surname,
    required this.email,
  });

  final String name;
  final String surname;
  final String email;

  Map<String, dynamic> toJson(String password) => <String, dynamic>{
    'name': name,
    'surname': surname,
    'email': email,
    'password': password,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'] as String,
    surname: json['surname'] as String,
    email: json['email'] as String,
  );

  @override
  String toString() =>
      'UserModel('
      'name: $name,'
      'surname: $surname,'
      'email: $email)';
}
