class Tutor {
  final String username;
  final String password;
  String token;

  static String usernameField = 'username';
  static String passwordField = 'password';
  static String tokenField = 'token';

  Tutor(
    this.username,
    this.password,
    this.token,
  );

  Tutor.fromNow(String username, String password, String token) : this(username, password, token);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[usernameField] = username;
    data[passwordField] = password;
    data[tokenField] = token;
    return data;
  }

  factory Tutor.fromJson(dynamic json) {
    return Tutor(
      json[usernameField] as String,
      json[passwordField] as String,
      json[tokenField] as String,
    );
  }

  factory Tutor.fromPartialJson(dynamic json, String password, String token) {
    return Tutor(
      json[usernameField] as String,
      json[passwordField] as String,
      json[tokenField] as String,
    );
  }

}
