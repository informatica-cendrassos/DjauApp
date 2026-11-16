import 'dart:convert';

import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/models/alumne.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('areNewNotifications', () {
    final alumne = Alumne(1, 'Nom', 'Cognoms');

    test('distinguishes positive and negative responses', () async {
      for (final (resultat, expected) in [('Sí', true), ('No', false)]) {
        final repository = NotificacionsRepository(
          httpClient: MockClient((_) async => http.Response.bytes(
                utf8.encode(jsonEncode({'resultat': resultat})),
                200,
              )),
        );

        expect(await repository.areNewNotifications('token', alumne), expected);
      }
    });

    test('propagates API errors instead of reporting no notifications',
        () async {
      final repository = NotificacionsRepository(
        httpClient: MockClient(
          (_) async => http.Response('{"detail":"error"}', 500),
        ),
      );

      await expectLater(
        repository.areNewNotifications('token', alumne),
        throwsA(isA<FetchDataException>()),
      );
    });

    test('rejects an unexpected result', () async {
      final repository = NotificacionsRepository(
        httpClient: MockClient(
          (_) async => http.Response('{"resultat":"unexpected"}', 200),
        ),
      );

      await expectLater(
        repository.areNewNotifications('token', alumne),
        throwsFormatException,
      );
    });
  });
}
