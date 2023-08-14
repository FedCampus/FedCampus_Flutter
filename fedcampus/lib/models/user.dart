class User {
  static Map<String, dynamic> mapOf(
      {required String userName, required String email, loggedIn = false}) {
    return {
      "userName": userName,
      "email": email,
      "loggedIn": loggedIn,
      "nickName": "",
      "avatarUrl": "",
      "type": "",
      "createdAt": ""
    };
  }
}
