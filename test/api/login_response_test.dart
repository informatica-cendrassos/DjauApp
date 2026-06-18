import 'package:cendrassos/api/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson accepts refresh omitted in refresh endpoint response', () {
      final response = LoginResponse.fromJson({
        'access': 'new_access_token',
      });

      expect(response.accessToken, 'new_access_token');
      expect(response.refreshToken, isEmpty);
    });

    test('fromJson accepts legacy token field', () {
      final response = LoginResponse.fromJson({
        'token': 'legacy_access_token',
      });

      expect(response.accessToken, 'legacy_access_token');
      expect(response.refreshToken, isEmpty);
    });

    test('fromJson accepts legacy refresh_token field', () {
      final response = LoginResponse.fromJson({
        'access': 'new_access_token',
        'refresh_token': 'legacy_refresh_token',
      });

      expect(response.accessToken, 'new_access_token');
      expect(response.refreshToken, 'legacy_refresh_token');
    });

    test('toJson uses the correct keys', () {
      final response = LoginResponse(
        accessToken: 'access_value',
        refreshToken: 'refresh_value',
      );

      expect(response.toJson(), {
        'access': 'access_value',
        'refresh': 'refresh_value',
      });
    });
  });
}
