#!/bin/bash

# Run this script two times, one for i686 (32Bit) and for the x86_64 (64Bit)
for ARCH in i686 x86_64; do
    export PKG_CONFIG_ALLOW_CROSS=1
    export PKG_CONFIG_PATH=/usr/${ARCH}-w64-mingw32/sys-root/mingw/lib/pkgconfig/
    export GTK_INSTALL_PATH=/usr/${ARCH}-w64-mingw32/sys-root/mingw/
    # build package
    source ~/.cargo/env
    cargo build --target=${ARCH}-pc-windows-gnu --release
    # extract package name and version from cargo
    export NAME=$(cargo pkgid | cut -d# -f2 | cut -d: -f1)
    export VERSION=$(cargo pkgid | cut -d# -f2 | cut -d: -f2)
    export NAME_VERSION="${NAME}-${VERSION}"
    export NAME_VERSION_ARCH=${NAME_VERSION}-windows-${ARCH}
    # create destination directory
    mkdir -p "${NAME_VERSION_ARCH}"
    cp target/${ARCH}-pc-windows-gnu/release/*.exe "${NAME_VERSION_ARCH}"
    # extract all dependencies to libs
    export DLLS=`peldd "${NAME_VERSION_ARCH}"/*.exe -t --ignore-errors`
    for DLL in $DLLS
    do cp "$DLL" "${NAME_VERSION_ARCH}"
    done
    # copy the gtk and additional files like the LICENSE and the README
    mkdir -p "${NAME_VERSION_ARCH}"/share/{themes,gtk-3.0}
    cp -r $GTK_INSTALL_PATH/share/glib-2.0/schemas "${NAME_VERSION_ARCH}"/share/glib-2.0
    cp -r $GTK_INSTALL_PATH/share/icons "${NAME_VERSION_ARCH}"/share/icons
    [ -d resources ] && cp -r resources "${NAME_VERSION_ARCH}"/
    [ -d share ] && cp -r share "${NAME_VERSION_ARCH}"/
    [ -f README.md ] && cp -r README.md "${NAME_VERSION_ARCH}"/
    [ -f LICENSE ] && cp -r LICENSE "${NAME_VERSION_ARCH}"/
    [ -f CHANGELOG ] && cp -r CHANGELOG "${NAME_VERSION_ARCH}"
    # reduce the binary size
    mingw-strip "${NAME_VERSION_ARCH}"/*
    # zip the whole package dir
    zip -r "${NAME_VERSION_ARCH}".zip "${NAME_VERSION_ARCH}"/*
    # Make windows installer if .nsi files exist
    for f in *.nsi; do [ -f ${f} ] && makensis ${f}; done
done
