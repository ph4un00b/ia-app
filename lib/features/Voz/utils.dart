import 'package:lola_ai_app/features/core/time.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

enum FolderKind {
  doc,
  temp,
}

Future<String> buildPath(
    {required FolderKind folder, required AudioEncoder encoder}) async {
  switch ((folder, encoder)) {
    case (FolderKind.doc, AudioEncoder.wav):
      final dir = await getApplicationDocumentsDirectory();
      var path = p.join(
        dir.path,
        'phaunus_doc_${formatTimestamp(DateTime.now())}.wav',
      );
      return path;
    case (FolderKind.temp, AudioEncoder.wav):
      final dir = await getTemporaryDirectory();
      var path = p.join(
        dir.path,
        'phaunus_tmp_${formatTimestamp(DateTime.now())}.wav',
      );
      return path;
    case (FolderKind.doc, AudioEncoder.aacLc):
      final dir = await getTemporaryDirectory();
      var path = p.join(
        dir.path,
        'phaunus_doc_${formatTimestamp(DateTime.now())}.m4a',
      );
      return path;
    case (FolderKind.temp, AudioEncoder.aacLc):
      final dir = await getTemporaryDirectory();
      var path = p.join(
        dir.path,
        'phaunus_tmp_${formatTimestamp(DateTime.now())}.m4a',
      );
      return path;
    case (_, _):
      throw UnimplementedError();
  }
}
