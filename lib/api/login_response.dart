class LoginResponse {
  String accessToken = "";
  String refreshToken = "";

  static String tokenField = 'access';
  static String refreshField = 'refresh';

  LoginResponse({this.accessToken = "", this.refreshToken = ""});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    accessToken = (json[tokenField] ?? '') as String;
    refreshToken = (json[refreshField] ?? '') as String;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[tokenField] = accessToken;
    data[refreshField] = refreshToken;
    return data;
  }
}
