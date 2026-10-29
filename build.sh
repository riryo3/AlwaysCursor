#!/bin/sh
# AlwaysCursor.app を組み立てる
# 使い方: sh build.sh
set -e
cd "$(dirname "$0")"

APP="AlwaysCursor.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# アイコン生成（make_icon.swift → iconset → icns）
swiftc make_icon.swift -o /tmp/alwayscursor_make_icon
ICONSET="$(mktemp -d)/AppIcon.iconset"
/tmp/alwayscursor_make_icon "$ICONSET"
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

# 本体（Apple Silicon / Intel 両対応のユニバーサルバイナリ）
swiftc -O -framework Cocoa -framework ServiceManagement -framework UniformTypeIdentifiers \
    -target arm64-apple-macos13.0 main.swift -o /tmp/AlwaysCursor-arm64
swiftc -O -framework Cocoa -framework ServiceManagement -framework UniformTypeIdentifiers \
    -target x86_64-apple-macos13.0 main.swift -o /tmp/AlwaysCursor-x86_64
lipo -create /tmp/AlwaysCursor-arm64 /tmp/AlwaysCursor-x86_64 -output "$APP/Contents/MacOS/AlwaysCursor"
cp Info.plist "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"
echo "できた: $APP"
