#!/bin/sh

set -e
set -u

URL="$1"
wget -q --show-progress -O tmp.deb "$URL"
ar x tmp.deb data.tar.xz
rm tmp.deb
tar xf data.tar.xz --strip-components 4 ./usr/share/gir-1.0
rm data.tar.xz
