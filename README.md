# Onager Scanner

Flutter-basierte Dokument-Scanner-App für Android von [Onager AI](https://onager.ai).

## App-Informationen

| Eigenschaft | Wert |
|---|---|
| Package | `ai.onager.scanner` |
| Namespace | `ai.onager.onager_scanner` |
| Min Android | 5.0 (API 21) |
| Framework | Flutter (Dart) |
| State | Riverpod |
| Navigation | GoRouter |

## Features

- Native Dokumentenscanner (cunning_document_scanner)
- Google Sign-In + Google Drive Upload (googleapis)
- On-Device OCR (Google ML Kit Text Recognition)
- Lokale Datenbank (sqflite)
- PDF-Export mit Passwortschutz
- Dunkel / Hell / System Theme

## Architektur

```
lib/
  core/
    database/     # sqflite AppDatabase
    router/       # GoRouter
    services/     # AuthService, DriveService
    theme/        # AppTheme, AppColors
  features/
    auth/         # SplashScreen, LoginScreen
    home/         # HomeScreen (Bibliothek)
    scan/         # CameraScreen, MultipageScreen
    edit/         # EditScreen (Filter, Crop, OCR)
    export/       # ExportScreen + DriveSheet
    settings/     # SettingsScreen
  shared/
    models/       # Document, ScannedPage
    widgets/      # AppWidgets, OnagerLogo
```

## Sicherheit

- `allowBackup="false"`, kein Cleartext-Traffic
- APK Signing v2/v3
- Kein hardcodierter API-Key
- Kameraberechtigungen korrekt gesetzt

## Legacy

Die ursprüngliche Release-APK (v1.0.0) sowie der Security-Report sind unter `releases/` archiviert.
Sicherheitsanalyse: [SECURITY_REPORT.md](SECURITY_REPORT.md)
