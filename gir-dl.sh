#!/bin/bash
set -e -u -o pipefail

MIRRORS="$1"
if [ $# -lt 2 ]; then
  MIRROR="mirrors.kernel.org"
else
  MIRROR="$2"
fi
wget -q --show-progress -O tmp.html "$MIRRORS"
URL=`cat tmp.html | grep -oP "http://$MIRROR/[^\"]+"`
rm tmp.html
echo $URL
wget -q --show-progress -O tmp.deb "$URL"
ar x tmp.deb data.tar.xz
rm tmp.deb
tar xf data.tar.xz --strip-components 4 ./usr/share/gir-1.0
rm data.tar.xz
