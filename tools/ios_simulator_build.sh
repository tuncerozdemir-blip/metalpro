#!/usr/bin/env bash
# macOS + Xcode gerektirir. Appetize'in kabul ettigi imzasiz .app zip'i uretir.
set -euo pipefail

cd "$(dirname "$0")/.."

flutter pub get
flutter build ios --simulator

ZIP="$PWD/MetalPro-ios-simulator.zip"
rm -f "$ZIP"
(
  cd build/ios/iphonesimulator
  zip -r "$ZIP" Runner.app
)

echo "Hazir: $ZIP"
echo "Appetize > Upload app > iOS adiminda bu zip dosyasini secin."
