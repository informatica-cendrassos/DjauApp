class QualitativaVisibleResponse {
  static const String resultatField = 'resultat';
  static const String visibleValue = 'Sí';
  static const String hiddenValue = 'No';

  final String resultat;

  const QualitativaVisibleResponse._(this.resultat);

  factory QualitativaVisibleResponse.fromJson(Map<String, dynamic> json) {
    final resultat = json[resultatField];
    if (resultat != visibleValue && resultat != hiddenValue) {
      throw const FormatException(
        'La resposta de visibilitat qualitativa no és vàlida',
      );
    }
    return QualitativaVisibleResponse._(resultat as String);
  }

  bool get isVisible => resultat == visibleValue;
}
