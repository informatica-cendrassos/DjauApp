import 'package:cendrassos/api/qualitativa_visible_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QualitativaVisibleResponse', () {
    test('recognizes the visible API result', () {
      final response = QualitativaVisibleResponse.fromJson({
        'resultat': 'Sí',
      });

      expect(response.isVisible, isTrue);
    });

    test('recognizes the hidden API result', () {
      final response = QualitativaVisibleResponse.fromJson({
        'resultat': 'No',
      });

      expect(response.isVisible, isFalse);
    });

    test('rejects a malformed API result', () {
      expect(
        () => QualitativaVisibleResponse.fromJson({'resultat': 'Potser'}),
        throwsFormatException,
      );
    });
  });
}
