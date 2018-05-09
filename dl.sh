#!/bin/sh
set -e

VER="bionic"

./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libatk1.0-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libgirepository1.0-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libpango1.0-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libgdk-pixbuf2.0-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libgtk-3-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libgtksourceview-3.0-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libsecret-1-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libvte-2.91-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libjavascriptcoregtk-4.0-dev/download security.ubuntu.com/ubuntu
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libsoup2.4-dev/download
./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/libwebkit2gtk-4.0-dev/download security.ubuntu.com/ubuntu


./reformat.sh
