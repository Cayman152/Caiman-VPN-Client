#!/bin/bash

Arch="$1"
OutputPath="$2"
Version="$3"

FileName="CaimanVPN-${Arch}.zip"
wget -nv -O $FileName "https://github.com/Cayman152/Caiman-VPN-Client/releases/latest/download/$FileName"
7z x $FileName
cp -rf CaimanVPN-${Arch}/* $OutputPath

PackagePath="CaimanVPN-Package-${Arch}"
mkdir -p "$PackagePath/CaimanVPN.app/Contents/Resources"
cp -rf "$OutputPath" "$PackagePath/CaimanVPN.app/Contents/MacOS"
cp -f "$PackagePath/CaimanVPN.app/Contents/MacOS/CaimanVPN.icns" "$PackagePath/CaimanVPN.app/Contents/Resources/AppIcon.icns"
echo "When this file exists, app will not store configs under this folder" > "$PackagePath/CaimanVPN.app/Contents/MacOS/NotStoreConfigHere.txt"
chmod +x "$PackagePath/CaimanVPN.app/Contents/MacOS/CaimanVPN"

cat >"$PackagePath/CaimanVPN.app/Contents/Info.plist" <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>English</string>
  <key>CFBundleDisplayName</key>
  <string>CaimanVPN</string>
  <key>CFBundleExecutable</key>
  <string>CaimanVPN</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIconName</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>com.caimanvpn.client</string>
  <key>CFBundleName</key>
  <string>CaimanVPN</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${Version}</string>
  <key>CSResourcesFileMapped</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>LSMinimumSystemVersion</key>
  <string>12.7</string>
</dict>
</plist>
EOF

create-dmg \
    --volname "CaimanVPN Installer" \
    --window-size 700 420 \
    --icon-size 100 \
    --icon "CaimanVPN.app" 160 185 \
    --hide-extension "CaimanVPN.app" \
    --app-drop-link 500 185 \
    "CaimanVPN-${Arch}.dmg" \
    "$PackagePath/CaimanVPN.app"
