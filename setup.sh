#!/usr/bin/env bash
# Prepara il progetto Android (cartella android/) e imposta il nome dell'app.
# Va eseguito una sola volta, dalla cartella principale del progetto.
set -e
if [ ! -d android ]; then
  flutter create . --platforms=android --project-name quiz_sana --org ch.quizsana --no-pub
  rm -f test/widget_test.dart
fi
sed -i 's|android:label="[^"]*"|android:label="Quiz SaNa ITA (inofficiale)"|' android/app/src/main/AndroidManifest.xml
echo "Fatto. Ora esegui: flutter pub get && flutter build apk --release"
