#!/bin/bash
wine-tkg() { [ -x "/bin/wine-tkg" ] && echo "RMT: wine-tkg present on system." && exit || echo "RMT: wine-tkg not present on system."; [ -x "$BINDIR/wine/bin/wine" ] && exit || echo "RMT: wine-tkg not found on relative path, downloading." && WRLS="$(curl -s https://api.github.com/repos/jc141x/wine-tkg-git/releases)" && DLRLS="$(echo "$WRLS" | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}')"; [ ! -f "wine-tkg.tar.lzma" ] && curl -L "$DLRLS" -o "wine-tkg.tar.lzma"; [ ! -f "wine-tkg.tar.lzma" ] && echo "RMT: Download failed." && exit || echo "RMT: wine-tkg.tar.lzma downloaded."; tar -xvf "wine-tkg.tar.lzma" && mv "wine" "$BINDIR/wine"; }

wine-ge() { [ -x "/bin/wine-ge" ] && echo "RMT: wine-ge present on system." && exit || echo "RMT: wine-ge not present on system."; [ -x "$BINDIR/wine/bin/wine" ] && exit || echo "RMT: wine-ge not found on relative path, downloading." && WRLS="$(curl -s https://api.github.com/repos/jc141x/wine-ge-custom/releases)" && DLRLS="$(echo "$WRLS" | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}')"; [ ! -f "wine-tkg.tar.lzma" ] && curl -L "$DLRLS" -o "wine-ge.tar.lzma"; [ ! -f "wine-ge.tar.lzma" ] && echo "RMT: Download failed." && exit || echo "RMT: wine-ge.tar.lzma downloaded."; tar -xvf "wine-ge.tar.lzma" && mv "wine" "$BINDIR/wine"; }

wine-tkg-nomingw() { [ -x "/bin/wine-tkg-nomingw" ] && echo "RMT: wine-tkg-nomingw present on system." && exit || echo "RMT: wine-ge not present on system."; [ -x "$BINDIR/wine/bin/wine" ] && exit || echo "RMT: wine-tkg-nomingw not found on relative path, downloading." && WRLS="$(curl -s https://api.github.com/repos/jc141x/wine-tkg-nomingw/releases)" && DLRLS="$(echo "$WRLS" | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}')"; [ ! -f "wine-tkg-nomingw.tar.lzma" ] && curl -L "$DLRLS" -o "wine-tkg-nomingw.tar.lzma"; [ ! -f "wine-tkg-nomingw.tar.lzma" ] && echo "RMT: Download failed." && exit || echo "RMT: wine-tkg-nomingw.tar.lzma downloaded."; tar -xvf "wine-tkg-nomingw.tar.lzma" && mv "wine" "$BINDIR/wine"; }

for i in "$@"; do
    if type "$i" &>/dev/null; then
       "$i"
    fi
done
