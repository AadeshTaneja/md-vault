#!/bin/bash
# Builds MD Vault.app with swiftc only — no Xcode project, no package manager.
#   ./build.sh              build into ./build
#   ./build.sh --install    build, then copy into /Applications
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/MD Vault.app"
BIN="$APP/Contents/MacOS/MDVault"
RES="$APP/Contents/Resources"
INSTALL=0
[[ "${1:-}" == "--install" ]] && INSTALL=1

SDK="$(xcrun --show-sdk-path)"
ARCH="$(uname -m)"

echo "==> Cleaning"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$RES"

echo "==> Compiling Swift sources ($ARCH)"
SOURCES=()
while IFS= read -r file; do SOURCES+=("$file"); done < <(find "$ROOT/Sources" -name '*.swift' | sort)
swiftc \
  -parse-as-library \
  -O -whole-module-optimization \
  -target "$ARCH-apple-macos14.0" \
  -sdk "$SDK" \
  -module-name MDVault \
  -o "$BIN" \
  "${SOURCES[@]}"

echo "==> Building icon"
ICONSET="$BUILD/AppIcon.iconset"
rm -rf "$ICONSET"
swift "$ROOT/Tools/MakeIcon.swift" "$ICONSET" >/dev/null
iconutil -c icns "$ICONSET" -o "$RES/AppIcon.icns"
rm -rf "$ICONSET"

echo "==> Assembling bundle"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"

echo "==> Signing (ad-hoc)"
codesign --force --sign - --timestamp=none "$APP" >/dev/null 2>&1 || \
  echo "    (ad-hoc signing skipped)"

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

if [[ $INSTALL -eq 1 ]]; then
  DEST="/Applications"
  [[ -w "$DEST" ]] || DEST="$HOME/Applications"
  mkdir -p "$DEST"
  echo "==> Installing to $DEST"
  rm -rf "$DEST/MD Vault.app"
  cp -R "$APP" "$DEST/"
  "$LSREGISTER" -f "$DEST/MD Vault.app"
  echo
  echo "Installed: $DEST/MD Vault.app"
  echo "Open a file:  open -a \"MD Vault\" some.md"
else
  "$LSREGISTER" -f "$APP"
  echo
  echo "Built: $APP"
  echo "Run:   open \"$APP\""
  echo "Install: ./build.sh --install"
fi
