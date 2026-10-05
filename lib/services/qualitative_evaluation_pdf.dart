import 'dart:typed_data';

import 'qualitative_evaluation_pdf_io.dart'
    if (dart.library.html) 'qualitative_evaluation_pdf_web.dart' as platform;

Future<void> downloadAndOpenQualitativeEvaluationPdf(
  Future<Uint8List> Function() download,
  int alumneId,
) async {
  final bytes = await download();
  await platform.openQualitativeEvaluationPdf(bytes, alumneId);
}
