#!/bin/bash
set -e

./gir-dl.sh https://packages.debian.org/unstable/amd64/libatk1.0-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libgirepository1.0-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libgraphene-1.0-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libgdk-pixbuf-2.0-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libgtk-3-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libgtk-4-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libharfbuzz-dev/download http.us.debian.org
./gir-dl.sh https://packages.debian.org/unstable/amd64/libpango1.0-dev/download http.us.debian.org

./reformat.sh
./fix.sh
