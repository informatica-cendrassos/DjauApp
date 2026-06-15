import 'package:cendrassos/models/resum_sortida.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResumSortida.fromJson', () {
    test('normalizes empty outing date to empty string', () {
      final resumSortida = ResumSortida.fromJson({
        'id': 7,
        'titol': 'Sortida',
        'data': '',
        'pagament': true,
        'realitzat': false,
      });

      expect(resumSortida.data, isEmpty);
      expect(resumSortida.hasDate, isFalse);
      expect(resumSortida.isBefore(DateTime.now()), isFalse);
    });
  });
}
