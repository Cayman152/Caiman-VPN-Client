#!/bin/bash

Arch="$1"
OutputPath="$2"
Version="$3"

FileName="CaimanVPN-${Arch}.zip"
wget -nv -O $FileName "https://github.com/Cayman152/Caiman-VPN-Client/releases/latest/download/$FileName"
7z x $FileName
cp -rf CaimanVPN-${Arch}/* $OutputPath

PackagePath="CaimanVPN-Package-${Arch}"
mkdir -p "${PackagePath}/DEBIAN"
mkdir -p "${PackagePath}/opt"
cp -rf $OutputPath "${PackagePath}/opt/CaimanVPN"
echo "When this file exists, app will not store configs under this folder" > "${PackagePath}/opt/CaimanVPN/NotStoreConfigHere.txt"

if [ $Arch = "linux-64" ]; then
    Arch2="amd64" 
else
    Arch2="arm64"
fi
echo $Arch2

# basic
cat >"${PackagePath}/DEBIAN/control" <<-EOF
Package: CaimanVPN
Version: $Version
Architecture: $Arch2
Maintainer: https://github.com/Cayman152/Caiman-VPN-Client
Depends: libc6 (>= 2.34), fontconfig (>= 2.13.1), desktop-file-utils (>= 0.26), xdg-utils (>= 1.1.3), coreutils (>= 8.32), bash (>= 5.1), libfreetype6 (>= 2.11)
Description: A GUI client for Windows and Linux, support Xray core and sing-box-core and others
EOF

cat >"${PackagePath}/DEBIAN/postinst" <<-EOF
if [ ! -s /usr/share/applications/CaimanVPN.desktop ]; then
    cat >/usr/share/applications/CaimanVPN.desktop<<-END
[Desktop Entry]
Name=CaimanVPN
Comment=A GUI client for Windows and Linux, support Xray core and sing-box-core and others
Exec=/opt/CaimanVPN/CaimanVPN
Icon=/opt/CaimanVPN/CaimanVPN.png
Terminal=false
Type=Application
Categories=Network;Application;
END
fi

update-desktop-database
EOF

sudo chmod 0755 "${PackagePath}/DEBIAN/postinst"
sudo chmod 0755 "${PackagePath}/opt/CaimanVPN/CaimanVPN"
sudo chmod 0755 "${PackagePath}/opt/CaimanVPN/AmazTool"

# Patch
# set owner to root:root
sudo chown -R root:root "${PackagePath}"
# set all directories to 755 (readable & traversable by all users)
sudo find "${PackagePath}/opt/CaimanVPN" -type d -exec chmod 755 {} +
# set all regular files to 644 (readable by all users)
sudo find "${PackagePath}/opt/CaimanVPN" -type f -exec chmod 644 {} +
# ensure main binaries are 755 (executable by all users)
sudo chmod 755 "${PackagePath}/opt/CaimanVPN/CaimanVPN" 2>/dev/null || true
sudo chmod 755 "${PackagePath}/opt/CaimanVPN/AmazTool" 2>/dev/null || true

# build deb package
sudo dpkg-deb -Zxz --build $PackagePath
sudo mv "${PackagePath}.deb" "CaimanVPN-${Arch}.deb"
