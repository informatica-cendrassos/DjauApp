import 'package:cendrassos/api/api_base_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiBaseHelper.isAuthEndpointPath', () {
    test('accepts login path with or without trailing slash', () {
      expect(ApiBaseHelper.isAuthEndpointPath('/api-token-auth'), isTrue);
      expect(ApiBaseHelper.isAuthEndpointPath('/api-token-auth/'), isTrue);
    });

    test('accepts refresh path with or without trailing slash', () {
      expect(ApiBaseHelper.isAuthEndpointPath('/api-token-refresh'), isTrue);
      expect(ApiBaseHelper.isAuthEndpointPath('/api-token-refresh/'), isTrue);
    });

    test('returns false for non-auth endpoints', () {
      expect(ApiBaseHelper.isAuthEndpointPath('/api/token/alumnes_associats/'),
          isFalse);
      expect(
          ApiBaseHelper.isAuthEndpointPath('/api/token/notificacions/news/1'),
          isFalse);
    });
  });
}
