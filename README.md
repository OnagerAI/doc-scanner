# Doc Scanner – Android App

Flutter-basierte Dokument-Scanner-App für Android mit Google ML Kit Integration.

## App-Informationen

| Eigenschaft | Wert |
|---|---|
| Package | `com.example.doc_scanner` |
| Version | 1.0.0 |
| Framework | Flutter (Dart) |
| Min Android | 5.0 (API 21) |
| Target Android | 15 (API 35) |
| Build-Tool | Android Gradle Plugin 8.11.1 |
| Architektur | arm64-v8a, armeabi-v7a, x86_64 |

## Features

- Dokumente scannen via Google ML Kit Document Scanner
- Fallback-Scanner via `cunning_document_scanner`
- Google Sign-In Integration
- URL Launcher (WebView)
- Firebase Integration

## Abhängigkeiten (aus APK)

- `google_mlkit_document_scanner` – KI-basiertes Dokumentenscanning
- `cunning_document_scanner` – Fallback-Scanner
- `firebase_core` – Firebase SDK
- `google_sign_in` – Google-Authentifizierung
- `url_launcher` – WebView/Browser-Links
- `androidx.datastore` – Lokaler Datenspeicher
- `androidx.profileinstaller` – App-Performance

## Security Report

Siehe [SECURITY_REPORT.md](SECURITY_REPORT.md) für die vollständige Sicherheitsanalyse.

## Release

Die Release-APK liegt unter `releases/app-release.apk`.

> **Hinweis:** Der Package-Name `com.example.doc_scanner` sollte vor einem Play-Store-Release
> auf einen eigenen Namespace geändert werden (z.B. `ai.onager.docscanner`).
