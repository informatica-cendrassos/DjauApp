import 'dart:typed_data';
import 'dart:io';

import 'package:cendrassos/api/exceptions.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> openQualitativeEvaluationPdf(Uint8List bytes, int alumneId) async {
  final directory = await getTemporaryDirectory();
  final file = File(
    '${directory.path}${Platform.pathSeparator}avaluacio-qualitativa-$alumneId.pdf',
  );
  await file.writeAsBytes(bytes, flush: true);

  final result = await OpenFilex.open(
    file.path,
    type: 'application/pdf',
    uti: 'com.adobe.pdf',
  );
  if (result.type != ResultType.done) {
    throw OpenDocumentException(
      result.message.isEmpty
          ? 'No s’ha pogut obrir el document.'
          : result.message,
    );
  }
}
