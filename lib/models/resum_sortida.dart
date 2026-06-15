import 'package:intl/intl.dart';

class ResumSortida {
  final int id;
  final String titol;
  final String data;
  final bool pagament;
  final bool realitzat;

  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  // Personalitzar els camps de login
  static String idField = 'id';
  static String titolField = 'titol';
  static String dataField = 'data';
  static String pagamentField = 'pagament';
  static String realitzatField = "realitzat";

  ResumSortida(
    this.id,
    this.titol,
    this.data,
    this.pagament,
    this.realitzat,
  );

  @override
  bool operator ==(Object other) =>
      other is ResumSortida &&
      other.runtimeType == runtimeType &&
      other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory ResumSortida.fromJson(dynamic json) {
    return ResumSortida(
      json[idField] as int,
      json[titolField] as String,
      ((json[dataField] ?? '') as String).trim(),
      json[pagamentField] as bool,
      json[realitzatField] as bool,
    );
  }

  bool get hasDate => data.trim().isNotEmpty;

  bool isBefore(DateTime date) {
    if (!hasDate) {
      return false;
    }

    DateTime dataSortida = formatter.parse(data);
    return dataSortida.isBefore(date);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dades = <String, dynamic>{};
    dades[idField] = id;
    dades[titolField] = titol;
    dades[dataField] = data;
    dades[pagamentField] = pagament;
    dades[realitzatField] = realitzat;
    return dades;
  }
}
