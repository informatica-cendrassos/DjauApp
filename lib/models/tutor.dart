import 'package:intl/intl.dart';

class Tutor {
  final String username;
  final String password;
  String token;
  late String lastSyncDate;

  static DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String usernameField = 'username';
  static String passwordField = 'password';
  static String tokenField = 'token';
  static String lastSyncDateField = "last_sync_date";

  Tutor(
    this.username,
    this.password,
    this.token,
    this.lastSyncDate,
  );

  void updateLastSyncDate() {
    lastSyncDate = formatter.format(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[usernameField] = username;
    data[passwordField] = password;
    data[tokenField] = token;
    data[lastSyncDateField] = lastSyncDate;
    return data;
  }

  factory Tutor.fromJson(dynamic json) {
    return Tutor(
      json[usernameField] as String,
      json[passwordField] as String,
      json[tokenField] as String,
      json[lastSyncDateField] as String,
    );
  }

  factory Tutor.fromPartialJson(dynamic json, String password, String token) {
    return Tutor(
      json[usernameField] as String,
      json[passwordField] as String,
      json[tokenField] as String,
      formatter.format(DateTime.now()),
    );
  }

}
