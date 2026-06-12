class Tutor {
  final String username;
  final String password;
  String token;
  String refreshToken;

  static String usernameField = 'username';
  static String passwordField = 'password';
  static String tokenField = 'token';
  static String refreshTokenField = 'refreshToken';

  Tutor(
    this.username,
    this.password,
    this.token,
    this.refreshToken,
  );

  Tutor.fromNow(String username, String password, String token,
      [String refreshToken = ""])
      : this(username, password, token, refreshToken);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[usernameField] = username;
    data[passwordField] = password;
    data[tokenField] = token;
    data[refreshTokenField] = refreshToken;
    return data;
  }

  factory Tutor.fromJson(dynamic json) {
    return Tutor(
      json[usernameField] as String,
      json[passwordField] as String,
      json[tokenField] as String,
      (json[refreshTokenField] ?? '') as String,
    );
  }

  factory Tutor.fromPartialJson(dynamic json, String password, String token) {
    return Tutor(
      json[usernameField] as String,
      json[passwordField] as String,
      json[tokenField] as String,
      (json[refreshTokenField] ?? '') as String,
    );
  }
}
