import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../shared/models/document.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;
  AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'onager_scanner.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE documents (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            pages TEXT NOT NULL,
            tags TEXT NOT NULL DEFAULT '[]',
            state TEXT NOT NULL DEFAULT 'draft',
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            driveFileId TEXT,
            drivePath TEXT,
            format TEXT NOT NULL DEFAULT 'pdf',
            quality TEXT NOT NULL DEFAULT 'high',
            passwordProtected INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Document>> getAllDocuments() async {
    final database = await db;
    final rows = await database.query('documents', orderBy: 'updatedAt DESC');
    return rows.map(Document.fromMap).toList();
  }

  Future<Document?> getDocument(String id) async {
    final database = await db;
    final rows = await database.query('documents', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Document.fromMap(rows.first);
  }

  Future<void> upsertDocument(Document doc) async {
    final database = await db;
    await database.insert(
      'documents',
      doc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDocument(String id) async {
    final database = await db;
    await database.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateState(String id, DocumentState state) async {
    final database = await db;
    await database.update(
      'documents',
      {'state': state.name, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDriveInfo(String id, String fileId, String path) async {
    final database = await db;
    await database.update(
      'documents',
      {
        'driveFileId': fileId,
        'drivePath': path,
        'state': DocumentState.synced.name,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalDocuments() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as c FROM documents');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> getTotalPages() async {
    final docs = await getAllDocuments();
    return docs.fold<int>(0, (sum, d) => sum + d.pageCount);
  }

  Future<int> getSyncedCount() async {
    final database = await db;
    final result = await database.rawQuery(
      "SELECT COUNT(*) as c FROM documents WHERE state = 'synced'",
    );
    return (result.first['c'] as int?) ?? 0;
  }
}
