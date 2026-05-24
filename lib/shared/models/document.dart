import 'dart:convert';

enum DocumentState { draft, uploading, synced, error }

enum DocumentTag {
  vertrag,
  rechnung,
  steuer,
  versicherung,
  ausweis,
  protokoll,
  finanzen,
  privat,
  wichtig,
  sonstiges,
}

extension DocumentTagLabel on DocumentTag {
  String get label => switch (this) {
        DocumentTag.vertrag => 'Vertrag',
        DocumentTag.rechnung => 'Rechnung',
        DocumentTag.steuer => 'Steuer',
        DocumentTag.versicherung => 'Versicherung',
        DocumentTag.ausweis => 'Ausweis',
        DocumentTag.protokoll => 'Protokoll',
        DocumentTag.finanzen => 'Finanzen',
        DocumentTag.privat => 'Privat',
        DocumentTag.wichtig => 'Wichtig',
        DocumentTag.sonstiges => 'Sonstiges',
      };
}

class ScannedPage {
  final String id;
  final String imagePath;
  final int index;
  final String? ocrText;
  final String filter;
  final int rotation;
  final DateTime createdAt;

  const ScannedPage({
    required this.id,
    required this.imagePath,
    required this.index,
    this.ocrText,
    this.filter = 'doc',
    this.rotation = 0,
    required this.createdAt,
  });

  ScannedPage copyWith({
    String? imagePath,
    int? index,
    String? ocrText,
    String? filter,
    int? rotation,
  }) =>
      ScannedPage(
        id: id,
        imagePath: imagePath ?? this.imagePath,
        index: index ?? this.index,
        ocrText: ocrText ?? this.ocrText,
        filter: filter ?? this.filter,
        rotation: rotation ?? this.rotation,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'index': index,
        'ocrText': ocrText,
        'filter': filter,
        'rotation': rotation,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ScannedPage.fromMap(Map<String, dynamic> m) => ScannedPage(
        id: m['id'] as String,
        imagePath: m['imagePath'] as String,
        index: m['index'] as int,
        ocrText: m['ocrText'] as String?,
        filter: m['filter'] as String? ?? 'doc',
        rotation: m['rotation'] as int? ?? 0,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}

class Document {
  final String id;
  final String title;
  final List<ScannedPage> pages;
  final List<String> tags;
  final DocumentState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? driveFileId;
  final String? drivePath;
  final String format;
  final String quality;
  final bool passwordProtected;

  const Document({
    required this.id,
    required this.title,
    required this.pages,
    this.tags = const [],
    this.state = DocumentState.draft,
    required this.createdAt,
    required this.updatedAt,
    this.driveFileId,
    this.drivePath,
    this.format = 'pdf',
    this.quality = 'high',
    this.passwordProtected = false,
  });

  int get pageCount => pages.length;

  int get wordCount => pages
      .map((p) => p.ocrText?.split(RegExp(r'\s+')).length ?? 0)
      .fold(0, (a, b) => a + b);

  String get tagLabel => tags.isNotEmpty ? tags.first : '';

  Document copyWith({
    String? title,
    List<ScannedPage>? pages,
    List<String>? tags,
    DocumentState? state,
    DateTime? updatedAt,
    String? driveFileId,
    String? drivePath,
    String? format,
    String? quality,
    bool? passwordProtected,
  }) =>
      Document(
        id: id,
        title: title ?? this.title,
        pages: pages ?? this.pages,
        tags: tags ?? this.tags,
        state: state ?? this.state,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        driveFileId: driveFileId ?? this.driveFileId,
        drivePath: drivePath ?? this.drivePath,
        format: format ?? this.format,
        quality: quality ?? this.quality,
        passwordProtected: passwordProtected ?? this.passwordProtected,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'pages': jsonEncode(pages.map((p) => p.toMap()).toList()),
        'tags': jsonEncode(tags),
        'state': state.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'driveFileId': driveFileId,
        'drivePath': drivePath,
        'format': format,
        'quality': quality,
        'passwordProtected': passwordProtected ? 1 : 0,
      };

  factory Document.fromMap(Map<String, dynamic> m) {
    final pagesJson = jsonDecode(m['pages'] as String) as List;
    final tagsJson = jsonDecode(m['tags'] as String) as List;
    return Document(
      id: m['id'] as String,
      title: m['title'] as String,
      pages: pagesJson.map((p) => ScannedPage.fromMap(p as Map<String, dynamic>)).toList(),
      tags: tagsJson.cast<String>(),
      state: DocumentState.values.firstWhere(
        (s) => s.name == m['state'],
        orElse: () => DocumentState.draft,
      ),
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
      driveFileId: m['driveFileId'] as String?,
      drivePath: m['drivePath'] as String?,
      format: m['format'] as String? ?? 'pdf',
      quality: m['quality'] as String? ?? 'high',
      passwordProtected: (m['passwordProtected'] as int? ?? 0) == 1,
    );
  }
}
