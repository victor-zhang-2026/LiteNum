#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
configuration="${1:-release}"
sdk="${LITENUM_MACOS_SDK:-$(xcrun --show-sdk-path)}"
swift build -c "$configuration" --sdk "$sdk"
bin_dir="$(swift build -c "$configuration" --sdk "$sdk" --show-bin-path)"
"$bin_dir/LiteNum" --export-artwork "$PWD/design"
iconutil -c icns design/LiteNum.iconset -o Resources/LiteNum.icns
bundle="build/LiteNum.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources"
cp "$bin_dir/LiteNum" "$bundle/Contents/MacOS/LiteNum"
cp Resources/Info.plist "$bundle/Contents/Info.plist"
cp Resources/LiteNum.icns "$bundle/Contents/Resources/"
codesign --force --sign - "$bundle"
codesign --verify --deep --strict "$bundle"
echo "$PWD/$bundle"
