class LoginResponse {
  String accessToken = "";
  String refreshToken = "";

  static String tokenField = 'access';
  static String refreshField = 'refresh';
  static String legacyTokenField = 'token';
  static String legacyRefreshField = 'refresh_token';

  LoginResponse({this.accessToken = "", this.refreshToken = ""});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    accessToken = _readString(json, [tokenField, legacyTokenField]);
    refreshToken = _readString(json, [refreshField, legacyRefreshField]);
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[tokenField] = accessToken;
    data[refreshField] = refreshToken;
    return data;
  }
}
