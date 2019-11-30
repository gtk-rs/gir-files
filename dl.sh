#!/bin/sh
set -e

VER="eoan"
ALLOW_DOWNLOAD_FROM_DEBIAN="no"

dl_stuff () {
    echo "==> Downloading $1..."
    if [ $ALLOW_DOWNLOAD_FROM_DEBIAN = "no" ]; then
        ./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/$1/download || echo '!!> Failed to download from ubuntu...'
    else
        ./gir-dl.sh https://packages.debian.org/experimental/amd64/$1/download http.us.debian.org || \
         (echo '!!> Failed to download from debian, trying ubuntu...' && \
          ./gir-dl.sh https://packages.ubuntu.com/$VER/amd64/$1/download)
    fi
}

dl_stuff libatk1.0-dev
dl_stuff libgirepository1.0-dev
dl_stuff libpango1.0-dev
dl_stuff libgdk-pixbuf2.0-dev
dl_stuff libgtk-3-dev
dl_stuff libgtksourceview-3.0-dev
dl_stuff libsecret-1-dev
dl_stuff libvte-2.91-dev
dl_stuff libjavascriptcoregtk-4.0-dev
dl_stuff libsoup2.4-dev
dl_stuff libwebkit2gtk-4.0-dev

# version 4
ALLOW_DOWNLOAD_FROM_DEBIAN="yes"
dl_stuff libgtk-4-dev

./reformat.sh
