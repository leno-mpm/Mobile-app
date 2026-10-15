class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String identification;

  const UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.identification,
  });

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? identification,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      identification: identification ?? this.identification,
    );
  }
}
