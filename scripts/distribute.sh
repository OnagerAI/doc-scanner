#!/bin/bash
# Onager Scanner — Firebase App Distribution Upload
# Verwendung: ./scripts/distribute.sh [debug|release] "Release Notes"

set -e

MODE=${1:-debug}
NOTES=${2:-"Neuer Build"}
FIREBASE=/home/artur/.nvm/versions/node/v24.15.0/bin/firebase
SA_KEY=~/.config/onager-scanner/firebase-adminsdk.json
APP_ID="1:74193723216:android:2f1aa8e339238ca3689655"
TESTER="shachnev.artur@googlemail.com"

echo "▶ Baue $MODE APK..."
flutter build apk --$MODE

if [ "$MODE" = "release" ]; then
  APK="build/app/outputs/flutter-apk/app-release.apk"
else
  APK="build/app/outputs/flutter-apk/app-debug.apk"
fi

echo "▶ Lade hoch zu Firebase App Distribution..."
GOOGLE_APPLICATION_CREDENTIALS=$SA_KEY \
  $FIREBASE appdistribution:distribute "$APK" \
    --app "$APP_ID" \
    --release-notes "$NOTES" \
    --testers "$TESTER" \
    --project onager-scanner

echo "✓ Fertig! App ist in Firebase App Distribution verfügbar."
