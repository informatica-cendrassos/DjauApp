class Alumne {
  final int id;
  final String nom;
  final String cognoms;

  // Personalitzar els camps de login
  static const String idField = 'id';
  static String nomField = 'nom';
  static String cognomsField = 'cognoms';

  Alumne(
    this.id,
    this.nom,
    this.cognoms,
  );

  String nomComplet() {
    return "$nom $cognoms";
  }

  @override
  bool operator ==(Object other) => other is Alumne && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Alumne.fromJson(dynamic json) {
    return Alumne(
      json[idField] as int,
      json[nomField] as String,
      json[cognomsField] as String,
    );
  }

  factory Alumne.fromPartialJson(dynamic json, String password, String token) {
    return Alumne(
      json[idField] as int,
      json[nomField] as String,
      json[cognomsField] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[idField] = id;
    data[nomField] = nom;
    data[cognomsField] = cognoms;
    return data;
  }
}
