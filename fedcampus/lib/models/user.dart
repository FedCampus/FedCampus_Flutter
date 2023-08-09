class User {
  User({
    required this.userName,
    required this.email,
  });

  String userName;
  String email;
  bool loggedIn = false;
  String? nickname;
  String? avatarUrl;
  String? type;
  String? createdAt;
}
