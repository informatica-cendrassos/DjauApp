import 'package:cendrassos/api/api_base_helper.dart';
import 'package:cendrassos/api/login_response.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

  group('ApiBaseHelper.getBytes', () {
    test('returns PDF bytes from a successful request', () async {
      final helper = ApiBaseHelper(
        () async => LoginResponse(accessToken: 'refreshed_token'),
        httpClient: MockClient((request) async {
          expect(request.url, ApiBaseHelper.createUrl('/qualitativa/1'));
          expect(request.headers['Authorization'], 'Bearer access_token');
          expect(request.headers['Accept'], 'application/pdf');
          return http.Response.bytes(
            [37, 80, 68, 70],
            200,
            headers: {'content-type': 'application/pdf'},
          );
        }),
      );

      final bytes = await helper.getBytes('/qualitativa/1', {
        'Authorization': 'Bearer access_token',
        'Accept': 'application/pdf',
      });

      expect(bytes, [37, 80, 68, 70]);
    });

    test('retries the PDF request with a refreshed token after a 401',
        () async {
      var requests = 0;
      final helper = ApiBaseHelper(
        () async => {'access': 'refreshed_token'},
        httpClient: MockClient((request) async {
          requests++;
          if (requests == 1) {
            expect(request.headers['Authorization'], 'Bearer expired_token');
            return http.Response('{"detail":"Token caducat"}', 401);
          }

          expect(request.headers['Authorization'], 'Bearer refreshed_token');
          return http.Response.bytes([37, 80, 68, 70], 200);
        }),
      );

      final bytes = await helper.getBytes('/qualitativa/1', {
        'Authorization': 'Bearer expired_token',
      });

      expect(bytes, [37, 80, 68, 70]);
      expect(requests, 2);
    });
  });
}
