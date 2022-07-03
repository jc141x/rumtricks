#!/bin/bash
wine-tkg() { [ -x "/bin/wine-tkg1" ] && echo "RMT: Detected wine-tkg installed on system." && exit || echo "RMT: wine-tkg not detected locally."
[ -x "$BINDIR/wine/bin/wine" ]  && echo "RMT: wine-tkg found on relative path." && exit || echo "RMT: wine-tkg not found on relative path."
[ ! -f "$PWD/wine-tkg.tar.lzma" ] && echo "RMT: wine-tkg.tar.lzma not found, downloading." && wget $(curl -s https://api.github.com/repos/jc141x/wine-tkg-git/releases/latest | grep 'browser_' | cut -d\" -f4) && wget --show-progress "$URL"
[ ! -f "$PWD/wine-tkg.tar.lzma" ] && echo "RMT: Download failed, check internet connection." && exit || echo "RMT: wine-tkg.tar.lzma downloaded."
echo "RMT: Extracting wine-tkg" && tar -xvf "$PWD/wine-tkg.tar.lzma" > /dev/null && mv "wine" "$BINDIR/wine"; }

wine-ge() { [ -x "/bin/wine-ge" ] && echo "RMT: Detected wine-ge installed on system." && exit || echo "RMT: wine-ge not detected locally."
[ -x "$BINDIR/wine/bin/wine" ]  && echo "RMT: wine-ge found on relative path." && exit || echo "RMT: wine-ge not found on relative path."
[ ! -f "$PWD/wine-ge.tar.lzma" ] && echo "RMT: wine-ge.tar.lzma not found, downloading." && URL=$(curl -v https://api.github.com/repos/jc141x/wine-ge-custom/releases/latest 2>&1 | grep -v ant | grep browser_download_url | grep -v .asc | cut -d '"' -f 4) && wget --show-progress -O "wine-ge.tar.lzma" $URL && LZMA="$(find . -maxdepth 1 -name "*.lzma")"
[ ! -f "$PWD/wine-ge.tar.lzma" ] && echo "RMT: Download failed, check internet connection." && exit || echo "RMT: wine-ge.tar.lzma downloaded."
echo "RMT: Extracting wine-ge" && tar -xvf "$PWD/wine-ge.tar.lzma" > /dev/null && mv "wine" "$BINDIR/wine"; }

wine-tkg-nomingw() { [ -x "/bin/wine-tkg-nomingw" ] && echo "RMT: Detected wine-tkg-nomingw installed on system." && exit || echo "RMT: wine-tkg-nomingw not detected locally."
[ -x "$BINDIR/wine/bin/wine" ]  && echo "RMT: wine-tkg-nomingw found on relative path." && exit || echo "RMT: wine-tkg-nomingw not found on relative path."
[ ! -f "$PWD/wine-tkg-nomingw.tar.lzma" ] && echo "RMT: wine-tkg-nomingw.tar.lzma not found, downloading." && URL=$(curl -v https://api.github.com/repos/jc141x/wine-tkg-nomingw/releases/latest 2>&1 | grep -v ant | grep browser_download_url | grep -v .asc | cut -d '"' -f 4) && wget --show-progress -O "wine-tkg-nomingw.tar.lzma" $URL && LZMA="$(find . -maxdepth 1 -name "*.lzma")"
[ ! -f "$PWD/wine-tkg-nomingwa" ] && echo "RMT: Download failed, check internet connectio.n" && exit || echo "RMT: wine-tkg-nomingw.tar.lzma downloaded."
echo "RMT: Extracting wine-tkg-nomingw" && tar -xvf "$PWD/wine-tkg-nomingw.tar.lzma" > /dev/null && mv "wine" "$BINDIR/wine"; }

for i in "$@"; do
    if type "$i" &>/dev/null; then
       "$i"
    fi
done
