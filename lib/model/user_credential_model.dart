class UserCredentialModel {
  final String userId;
  final String password;

  const UserCredentialModel({required this.userId, required this.password});

  UserCredentialModel copyWith({String? password}) {
    return UserCredentialModel(
      userId: userId,
      password: password ?? this.password,
    );
  }
}
