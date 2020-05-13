#!/bin/bash

for ARCH in i686 x86_64; do
  export PKG_CONFIG_ALLOW_CROSS=1
  export PKG_CONFIG_PATH=/usr/${ARCH}-w64-mingw32/sys-root/mingw/lib/pkgconfig/
  export GTK_INSTALL_PATH=/usr/${ARCH}-w64-mingw32/sys-root/mingw/

  #statements
  source ~/.cargo/env
  cargo build --target=${ARCH}-pc-windows-gnu --release

  mkdir package-windows-${ARCH}
  cp target/${ARCH}-pc-windows-gnu/release/*.exe package-windows-${ARCH}

  export DLLS=`peldd package-windows-${ARCH}/*.exe -t --ignore-errors`
  for DLL in $DLLS
      do cp "$DLL" package-windows-${ARCH}
  done

  mkdir -p package-windows-${ARCH}/share/{themes,gtk-3.0}
  cp -r $GTK_INSTALL_PATH/share/glib-2.0/schemas package-windows-${ARCH}/share/glib-2.0
  cp -r $GTK_INSTALL_PATH/share/icons package-windows-${ARCH}/share/icons
  [ -d resources ] && cp -r resources package-windows-${ARCH}/
  [ -d share ] && cp -r share package-windows-${ARCH}/
  [ -f README.md ] && cp -r README.md package-windows-${ARCH}/
  [ -f LICENSE ] && cp -r LICENSE package-windows-${ARCH}/
  #cp -r ~/Windows10 package/share/themes

  cat << EOF > package-windows-${ARCH}/share/gtk-3.0/settings.ini
[Settings]
gtk-theme-name = Windows10
gtk-font-name = Segoe UI 10
gtk-xft-rgba = rgb
gtk-xft-antialias = 1
EOF

  mingw-strip package-windows-${ARCH}/* || true

  zip -r package-windows-${ARCH}.zip package-windows-${ARCH}/*

done
