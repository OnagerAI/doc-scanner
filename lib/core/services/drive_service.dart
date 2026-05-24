import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../shared/models/document.dart';

final _googleSignIn = GoogleSignIn(
  scopes: ['https://www.googleapis.com/auth/drive.file'],
);

final driveServiceProvider = Provider<DriveService>((ref) => DriveService());

class DriveUploadProgress {
  final double progress;
  final String stage; // uploading, indexing, done, error
  final String? fileId;
  final String? drivePath;
  const DriveUploadProgress(this.progress, this.stage, {this.fileId, this.drivePath});
}

class DriveService {
  Future<drive.DriveApi?> _getApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  Future<String?> _ensureFolder(drive.DriveApi api, String folderName, {String? parentId}) async {
    final query = StringBuffer("mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false");
    if (parentId != null) query.write(" and '$parentId' in parents");

    final result = await api.files.list(q: query.toString(), spaces: 'drive', $fields: 'files(id,name)');
    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id;
    }

    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    if (parentId != null) folder.parents = [parentId];

    final created = await api.files.create(folder);
    return created.id;
  }

  Stream<DriveUploadProgress> uploadDocument(Document doc, File file) async* {
    yield const DriveUploadProgress(0, 'uploading');

    try {
      final api = await _getApi();
      if (api == null) {
        yield const DriveUploadProgress(0, 'error');
        return;
      }

      final now = DateTime.now();
      final scansId = await _ensureFolder(api, 'Scans');
      final yearId = await _ensureFolder(api, '${now.year}', parentId: scansId);
      final monthNames = ['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'];
      final monthId = await _ensureFolder(api, monthNames[now.month - 1], parentId: yearId);

      final drivePath = 'Mein Drive / Scans / ${now.year} / ${monthNames[now.month - 1]}';

      yield const DriveUploadProgress(0.15, 'uploading');

      final mimeType = doc.format == 'pdf' ? 'application/pdf' : 'image/jpeg';
      final driveFile = drive.File()
        ..name = '${doc.title}.${doc.format}'
        ..parents = [monthId!]
        ..description = 'Gescannt mit Onager Scanner';

      final media = drive.Media(file.openRead(), file.lengthSync(), contentType: mimeType);

      final created = await api.files.create(driveFile, uploadMedia: media, $fields: 'id,name');

      yield const DriveUploadProgress(0.92, 'indexing');
      await Future.delayed(const Duration(milliseconds: 800));
      yield DriveUploadProgress(1.0, 'done', fileId: created.id, drivePath: drivePath);

    } catch (e) {
      yield const DriveUploadProgress(0, 'error');
    }
  }

  Future<String?> getWebViewLink(String fileId) async {
    final api = await _getApi();
    if (api == null) return null;
    final file = await api.files.get(fileId, $fields: 'webViewLink') as drive.File;
    return file.webViewLink;
  }
}
