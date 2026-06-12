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
