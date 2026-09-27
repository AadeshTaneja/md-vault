#!/bin/bash
# Packages build/MD Vault.app into a distributable .dmg.
# Run ./build.sh first.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/MD Vault.app"
VERSION="$(defaults read "$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo 1.0)"
STAGE="$ROOT/build/dmg"
DMG="$ROOT/build/MD-Vault-$VERSION.dmg"

[[ -d "$APP" ]] || { echo "No app bundle. Run ./build.sh first."; exit 1; }

echo "==> Staging"
rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

echo "==> Creating disk image"
hdiutil create \
  -volname "MD Vault" \
  -srcfolder "$STAGE" \
  -ov -format UDZO \
  "$DMG" >/dev/null

rm -rf "$STAGE"
echo
echo "Built: $DMG"
shasum -a 256 "$DMG"
