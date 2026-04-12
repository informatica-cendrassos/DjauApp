// @JsonSerializable()

class Login {
  String username = "";
  String contrasenya = "";

  static String usernameField = 'username';
  static String passwordField = 'password';

  Login(this.username, this.contrasenya);

  factory Login.fromJson(dynamic json) {
    return Login(json[usernameField] as String, json[passwordField] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[usernameField] = username;
    data[passwordField] = contrasenya;
    return data;
  }

  @override
  toString() {
    return '{ $username, $contrasenya }';
  }
}
