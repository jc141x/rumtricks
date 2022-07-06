#!/bin/bash
wine-tkg() { [ -x "/bin/wine-tkg" ] && echo -n "RMT: Detected wine-tkg installed on system. | " && exit || echo -n "RMT: wine-tkg not detected locally. | "
[ -x "$BINDIR/wine/bin/wine" ]  && echo -n "RMT: wine-tkg found on relative path. | " && exit || echo -n "RMT: wine-tkg not found on relative path. | "
[ ! -f "$PWD/wine-tkg.tar.lzma" ] && echo -n "RMT: wine-tkg.tar.lzma not found, downloading. | " && URL="$(curl -s https://api.github.com/repos/jc141x/wine-tkg-git/releases | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}' | head -n 1)" && curl -L "$URL" -o "wine-tkg.tar.lzma"
[ ! -f "$PWD/wine-tkg.tar.lzma" ] && echo -n "RMT: Download failed, check internet connection. | " && exit || echo -n "RMT: wine-tkg.tar.lzma downloaded. | "
echo -n "RMT: Extracting wine-tkg. | " && tar -xvf "$PWD/wine-tkg.tar.lzma" > /dev/null && mv "wine" "$BINDIR/wine"; }

wine-ge() { [ -x "/bin/wine-ge" ] && echo -n "RMT: Detected wine-ge installed on system. | " && exit || echo -n "RMT: wine-ge not detected locally. | "
[ -x "$BINDIR/wine/bin/wine" ]  && echo -n "RMT: wine-ge found on relative path. | " && exit || echo -n "RMT: wine-ge not found on relative path. | "
[ ! -f "$PWD/wine-ge.tar.lzma" ] && echo -n "RMT: wine-ge.tar.lzma not found, downloading. | " && URL="$(curl -s https://api.github.com/repos/jc141x/wine-ge-custom/releases | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}' | head -n 1)" && curl -L "$URL" -o "wine-ge.tar.lzma"
[ ! -f "$PWD/wine-ge.tar.lzma" ] && echo -n "RMT: Download failed, check internet connection. | " && exit || echo -n "RMT: wine-ge.tar.lzma downloaded. | "
echo -n "RMT: Extracting wine-ge. | " && tar -xvf "$PWD/wine-ge.tar.lzma" > /dev/null && mv "wine" "$BINDIR/wine"; }

wine-tkg-nomingw() { [ -x "/bin/wine-tkg-nomingw" ] && echo -n "RMT: Detected wine-tkg-nomingw installed on system. | " && exit || echo -n "RMT: wine-tkg-nomingw not detected locally. | "
[ -x "$BINDIR/wine/bin/wine" ]  && echo -n "RMT: wine-tkg-nomingw found on relative path. | " && exit || echo -n "RMT: wine-tkg-nomingw not found on relative path. | "
[ ! -f "$PWD/wine-tkg-nomingw.tar.lzma" ] && echo -n "RMT: wine-tkg-nomingw.tar.lzma not found, downloading. | " && URL="$(curl -s https://api.github.com/repos/jc141x/wine-tkg-nomingw/releases | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}' | head -n 1)" && curl -L "$URL" -o "wine-tkg-nomingw.tar.lzma"
[ ! -f "$PWD/wine-tkg-nomingwa" ] && echo -n "RMT: Download failed, check internet connection. | " && exit || echo -n "RMT: wine-tkg-nomingw.tar.lzma downloaded. | "
echo -n "RMT: Extracting wine-tkg-nomingw. | " && tar -xvf "$PWD/wine-tkg-nomingw.tar.lzma" > /dev/null && mv "wine" "$BINDIR/wine"; }

for i in "$@"; do
    if type "$i" &>/dev/null; then
       "$i"
    fi
done
