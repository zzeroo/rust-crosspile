#!/bin/bash

echo "whoami: $(whoami)"
echo "pwd: $(pwd)"
echo "ls -lsa (pwd):"
$(ls -lsa pwd)

for ARCH in i686 x86_64; do
  export PKG_CONFIG_ALLOW_CROSS=1
  export PKG_CONFIG_PATH=/usr/${ARCH}-w64-mingw32/sys-root/mingw/lib/pkgconfig/
  export GTK_INSTALL_PATH=/usr/${ARCH}-w64-mingw32/sys-root/mingw/

  #statements
  source ~/.cargo/env
  cargo build --target=${ARCH}-pc-windows-gnu --release

  mkdir package-${ARCH}
  cp target/${ARCH}-pc-windows-gnu/release/*.exe package-${ARCH}

  export DLLS=`peldd package-${ARCH}/*.exe -t --ignore-errors`
  for DLL in $DLLS
      do cp "$DLL" package-${ARCH}
  done

  mkdir -p package-${ARCH}/share/{themes,gtk-3.0}
  cp -r $GTK_INSTALL_PATH/share/glib-2.0/schemas package-${ARCH}/share/glib-2.0
  cp -r $GTK_INSTALL_PATH/share/icons package-${ARCH}/share/icons
  [ -d resources ] && cp -r resources package-${ARCH}/
  [ -d share ] && cp -r share package-${ARCH}/
  [ -f README.md ] && cp -r README.md package-${ARCH}/
  [ -f LICENSE ] && cp -r LICENSE package-${ARCH}/
  #cp -r ~/Windows10 package/share/themes

  cat << EOF > package-${ARCH}/share/gtk-3.0/settings.ini
[Settings]
gtk-theme-name = Windows10
gtk-font-name = Segoe UI 10
gtk-xft-rgba = rgb
gtk-xft-antialias = 1
EOF

  mingw-strip package-${ARCH}/* || true

  zip -r package-${ARCH}.zip package-${ARCH}/*

done
