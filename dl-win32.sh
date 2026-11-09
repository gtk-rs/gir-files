#!/usr/bin/env sh

# Resolve the latest package file name from the repo listing: the
# packages.msys2.org search API's "exact" match prefers the msys repo
# package for glib2, whose version doesn't match the mingw-w64 package.
latest() {
    wget -qO- "https://repo.msys2.org/mingw/ucrt64/" | \
        grep -o "$1-[0-9][^\"]*pkg\.tar\.zst" | sort -Vu | tail -1
}

GTK_PACKAGE=$(latest mingw-w64-ucrt-x86_64-gtk4)

wget -qO- "https://mirror.msys2.org/mingw/ucrt64/$GTK_PACKAGE" | \
    zstdcat - | tar xO "ucrt64/share/gir-1.0/GdkWin32-4.0.gir" > GdkWin32-4.0.gir

# -x ucrt64/share/gir-1.0/GLibWin32-2.0.gir -x ucrt64/share/gir-1.0/GioWin32-2.0.gir
GLIB_PACKAGE=$(latest mingw-w64-ucrt-x86_64-glib2)

wget -qO- "https://mirror.msys2.org/mingw/ucrt64/$GLIB_PACKAGE" | \
    zstdcat - | tar -x "ucrt64/share/gir-1.0/GLibWin32-2.0.gir" -x "ucrt64/share/gir-1.0/GioWin32-2.0.gir"
mv ucrt64/share/gir-1.0/*.gir .
rm -r ucrt64
