import 'package:cendrassos/models/sortida.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sortida.fromJson', () {
    test('normalizes empty payment deadline to empty string', () {
      final sortida = Sortida.fromJson({
        'titol': 'Sortida',
        'desde': '2026-04-22 09:00:00',
        'finsa': '2026-04-22 14:00:00',
        'programa': 'Programa',
        'preu': '12.50',
        'dataLimitPagament': '',
        'realitzat': false,
        'idPagament': 1001,
      });

      expect(sortida.dataLimit, isEmpty);
      expect(sortida.hasPaymentDeadline, isFalse);
      expect(sortida.isBefore(DateTime.now()), isFalse);
    });
  });
}
