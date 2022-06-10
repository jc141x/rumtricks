#!/bin/bash
wine-tkg() {
    [ -x "/bin/wine-tkg" ] && echo "RMT: Detected wine-tkg installed on system." && exit || echo "RMT: wine-tkg not detected locally, downloading from github."
    [ -x "$BINDIR/wine/bin/wine" ]  && echo "RMT: wine-tkg found on relative path." && exit || echo "RMT: wine-ge not found on relative path, downloading."
    latest_release="$(curl -s https://api.github.com/repos/jc141x/wine-tkg-git/releases | jq '[.[] | select(.tag_name | test(".*[^LoL]$"))][0]')"
    download_url="$(echo "$latest_release" | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}')"
    [ ! -f "wine-tkg.tar.lzma" ] && echo "RMT: wine-tkg.tar.lzma not found, downloading" && curl -L "$download_url" -o "wine-tkg.tar.lzma"
    [ ! -f "wine-tkg.tar.lzma" ] && echo "RMT: Download failed, check internet connection" && exit || echo "RMT: wine-tkg.tar.lzma downloaded"
    echo "RMT: Extracting wine-tkg" && tar -xvf "wine-tkg.tar.lzma" && mv "wine" "$BINDIR/wine"
}

wine-ge() {
    [ -x "/bin/wine-ge" ] && echo "RMT: Detected wine-ge installed on system." && exit || echo "RMT: wine-ge not detected on system."
    [ -x "$BINDIR/wine/bin/wine" ]  && echo "RMT: wine-ge found on relative path." && exit || echo "RMT: wine-ge not found on relative path, downloading."
    latest_release="$(curl -s https://api.github.com/repos/jc141x/wine-ge-custom/releases | jq '[.[] | select(.tag_name | test(".*[^LoL]$"))][0]')"
    download_url="$(echo "$latest_release" | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}')"
    [ ! -f "wine-ge.tar.lzma" ] && echo "RMT: wine-ge.tar.lzma not found, downloading" && curl -L "$download_url" -o "wine-ge.tar.lzma"
    [ ! -f "wine-ge.tar.lzma" ] && echo "RMT: Download failed, check internet connection" && exit || echo "RMT: wine-ge.tar.lzma downloaded"
    echo "RMT: Extracting wine-ge" && tar -xvf "wine-ge.tar.lzma" && mv "wine" "$BINDIR/wine"
}

wine-tkg-nomingw() {
    [ -x "/bin/wine-tkg-nomingw" ] && echo "RMT: Detected wine-tkg-nomingw installed on system." && exit || echo "RMT: wine-tkg-nomingw not detected on system."
    [ -x "$BINDIR/wine/bin/wine" ]  && echo "RMT: wine-tkg-nomingw found on relative path." && exit || echo "RMT: wine-tkg-nomingw not found on relative path, downloading."
    latest_release="$(curl -s https://api.github.com/repos/jc141x/wine-tkg-nomingw/releases | jq '[.[] | select(.tag_name | test(".*[^LoL]$"))][0]')"
    download_url="$(echo "$latest_release" | awk -F '["]' '/"browser_download_url":/ && /tar.lzma/ {print $4}')"
    [ ! -f "wine-tkg-nomingw.tar.lzma" ] && echo "RMT: wine-tkg-nomingw.tar.lzma not found, downloading" && curl -L "$download_url" -o "wine-tkg-nomingw.tar.lzma"
    [ ! -f "wine-tkg-nomingw.tar.lzma" ] && echo "RMT: Download failed, check internet connection" && exit || echo "RMT: wine-tkg-nomingw.tar.lzma downloaded"
    echo "RMT: Extracting wine-tkg-nomingw" && tar -xvf "wine-tkg-nomingw.tar.lzma" && mv "wine" "$BINDIR/wine"
}

for i in "$@"; do
    # Check if function exists
    if type "$i" &>/dev/null; then
        "$i"
    else
        echo "WARN: Command: '$i' does not exists. Try another command/option."
        echo
        print-usage
    fi
done
