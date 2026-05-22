# Security Report – Doc Scanner APK

**Datum:** 2026-05-22  
**Analysiert:** `app-release.apk` (19 MB)  
**Package:** `com.example.doc_scanner`  
**Version:** 1.0.0  

---

## Zusammenfassung

| Kategorie | Status | Bewertung |
|---|---|---|
| APK-Signatur | APK Signing Scheme v2/v3 | SICHER |
| Debuggable Flag | Nicht gesetzt | SICHER |
| Cleartext Traffic | Nicht erlaubt | SICHER |
| Hardcoded Secrets | Keine gefunden | SICHER |
| Permissions | 7 Permissions (2 gefährlich) | PRÜFEN |
| Package-Name | `com.example.*` | WARNUNG |
| Network Security Config | Nicht definiert | WARNUNG |
| Allow Backup | Nicht explizit gesetzt | WARNUNG |
| `android.permission.DUMP` | Ungewöhnlich für User-Apps | KRITISCH |

**Gesamtbewertung: BEDINGT SICHER – 3 Punkte müssen vor Release behoben werden**

---

## 1. APK-Signatur

**Status: OK**

- APK Signature Scheme **v2 und v3** erkannt (Position 18.9 MB im ZIP-Block)
- Moderner Signaturstandard – Manipulation der APK nach dem Signieren wird erkannt
- Keine v1-only (JAR) Signatur

---

## 2. Permissions-Analyse

### Verwendete Permissions

| Permission | Gefährlich? | Begründung |
|---|---|---|
| `INTERNET` | Nein | Notwendig für Firebase, ML Kit |
| `ACCESS_NETWORK_STATE` | Nein | Netzwerkstatus prüfen |
| `CAMERA` | **Ja** | Notwendig für Scanner-Funktion |
| `READ_EXTERNAL_STORAGE` | **Ja** | Dokumente lesen |
| `WRITE_EXTERNAL_STORAGE` | **Ja** | Gescannte Dokumente speichern |
| `BIND_JOB_SERVICE` | Nein | Hintergrundverarbeitung |
| **`DUMP`** | **KRITISCH** | Systemlogs lesen – **nicht für User-Apps!** |

### Befund: `android.permission.DUMP`

**Schweregrad: HOCH**

`android.permission.DUMP` erlaubt das Auslesen von System-Dump-Informationen.
Diese Permission ist für System-Apps reserviert. In einer User-App:
- Wird sie auf modernen Android-Versionen automatisch verweigert (Protection Level: `normal`/`dangerous`)
- Kann aber auf älteren Geräten oder Custom-ROMs Probleme verursachen
- Signalisiert möglicherweise eine versehentliche Debug-Dependency

**Empfehlung:** Permission aus `AndroidManifest.xml` entfernen.

---

## 3. Cleartext Traffic / Netzwerksicherheit

**Status: OK (mit Vorbehalt)**

- `usesCleartextTraffic` nicht explizit auf `true` gesetzt → Standard ist `false` ab Android 9+
- Keine explizite `network_security_config.xml` definiert

**Empfehlung:** Explizit eine `network_security_config.xml` anlegen:

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>
</network-security-config>
```

Und im Manifest referenzieren:
```xml
<application android:networkSecurityConfig="@xml/network_security_config" ...>
```

---

## 4. Debuggable Flag

**Status: OK**

- `android:debuggable` ist **nicht** auf `true` gesetzt
- Release-Build verhindert Debugging via ADB
- Keine Debug-Symbols im DEX-Code erkannt

---

## 5. Hardcoded Secrets / API Keys

**Status: OK – Keine gefunden**

Gescannt auf:
- Google API Keys (`AIza...`) → Keine gefunden
- Firebase Project-IDs → Keine in Plaintext
- OAuth Client-Secrets → Keine gefunden
- Hardcoded Passwörter/Tokens → Keine gefunden
- Interne IP-Adressen/Endpoints → Keine gefunden

**Hinweis:** Die Firebase-Konfiguration (`google-services.json`) wird korrekt zur Compile-Zeit eingebettet und ist nicht als Plaintext-String vorhanden.

---

## 6. Exportierte Komponenten

| Komponente | Typ | Exported | Risiko |
|---|---|---|---|
| `MainActivity` | Activity | Implizit (LAUNCHER) | Niedrig |
| `WebViewActivity` (Flutter URL Launcher) | Activity | Unklar | Mittel |
| `DocumentScannerFileProvider` | Provider | Nein (FileProvider) | Niedrig |
| `ProfileInstallReceiver` | Receiver | Ja (AndroidX) | Niedrig |
| `GmsDocumentScanningDelegateActivity` | Activity | Via ML Kit | Niedrig |

**Empfehlung:** `WebViewActivity` explizit auf `exported="false"` setzen, falls nicht über externe Intents genutzt:

```xml
<activity
    android:name="io.flutter.plugins.urllauncher.WebViewActivity"
    android:exported="false" />
```

---

## 7. Package-Name

**Status: WARNUNG**

- Aktueller Package-Name: `com.example.doc_scanner`
- `com.example.*` ist ein Platzhalter-Namespace (Standard bei Flutter-Projekten)
- **Nicht für den Play Store geeignet** – Google lehnt Apps mit `com.example` Package-Namen ab
- Änderung erfordert Anpassung in `android/app/build.gradle` und `AndroidManifest.xml`

**Empfehlung:** Umbenennen auf z.B. `ai.onager.docscanner` oder `de.yourcompany.docscanner`

---

## 8. Backup-Verhalten

**Status: WARNUNG**

- `android:allowBackup` nicht explizit auf `false` gesetzt
- Default auf älteren Androids: `true` → App-Daten können via ADB/Google Backup gespeichert werden
- Bei sensitiven Dokumenten ein Risiko

**Empfehlung:** Im Manifest explizit setzen:

```xml
<application
    android:allowBackup="false"
    android:fullBackupContent="false"
    ...>
```

---

## 9. Abhängigkeiten / Third-Party

| Bibliothek | Version | Sicherheitsstatus |
|---|---|---|
| Flutter Engine | Aktuell (AGP 8.11.1) | OK |
| Google ML Kit Document Scanner | Aktuell | OK |
| `cunning_document_scanner` (biz.cunning) | Unbekannt | Prüfen |
| Firebase | Eingebettet | OK |
| Google Sign-In | Via GMS | OK |
| AndroidX Profile Installer | Aktuell | OK |

**Hinweis:** `cunning_document_scanner` ist ein Community-Plugin – regelmäßig auf Updates prüfen.

---

## Empfehlungen (Priorisiert)

### MUSS (vor Release)

1. **`android.permission.DUMP` entfernen** – Nicht notwendig, potentiell problematisch
2. **Package-Name ändern** von `com.example.doc_scanner` zu eigenem Namespace
3. **`allowBackup="false"`** setzen zum Schutz gescannter Dokumente

### SOLLTE (Best Practice)

4. **Network Security Config** explizit definieren (`network_security_config.xml`)
5. **`WebViewActivity`** auf `exported="false"` setzen
6. **ProGuard/R8** aktivieren und Regeln für alle Bibliotheken pflegen

### KANN (Nice to Have)

7. **Certificate Pinning** für Firebase/Backend-Kommunikation implementieren
8. **Root Detection** via `SafetyNet` / `Play Integrity API` hinzufügen
9. **Screenshot-Schutz** via `FLAG_SECURE` für sensitive Screens aktivieren

---

## Fazit

Die App ist für eine **Version 1.0.0 in einem soliden Zustand**. Die kritischsten Punkte
(Debuggable, Cleartext Traffic, Hardcoded Secrets) sind korrekt gehandhabt.

Vor einem Play-Store-Release **müssen** Package-Name, `DUMP`-Permission und Backup-Einstellung
korrigiert werden. Die restlichen Punkte sind Best-Practice-Empfehlungen.
