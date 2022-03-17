#!/bin/bash
[ "$EUID" = "0" ] && exit
# All operations are relative to rumtricks' location
cd "$(dirname "$(realpath "$0")")" || exit 1

# Base download URL for the archives
BASE_URL="https://johncena141.eu.org:8141/johncena141/rumtricks/media/branch/main/archives"
DOWNLOAD_LOCATION="${XDG_CAHCE_HOME:-$HOME/.cache}/rumtricks"
mkdir -p "$DOWNLOAD_LOCATION"

# Use default prefix if nothing is exported
[ -z "$WINEPREFIX" ] && export WINEPREFIX="$HOME/.wine"

# Use 64bit prefix if nothing is exported
[ -z "$WINEARCH" ] && export WINEARCH="win64"

# Wine: don't complain about mono/gecko
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"
export WINEDEBUG="-all"

# Support custom Wine versions
[ -z "$WINE" ] && WINE="$(command -v wine)"
[ ! -x "$WINE" ] && echo "${WINE} is not an executable, exiting" && exit 1

[ -z "$WINE64" ] && WINE64="${WINE}64"
[ ! -x "$WINE64" ] && echo "${WINE64} is not an executable, exiting" && exit 1

[ -z "$WINESERVER" ] && WINESERVER="${WINE}server"
[ ! -x "$WINESERVER" ] && echo "${WINESERVER} is not an executable, exiting" && exit 1

download()
{
    command -v curl >/dev/null 2>&1 && curl --etag-save $DOWNLOAD_LOCATION/${1##*/}.etag --etag-compare $DOWNLOAD_LOCATION/${1##*/}.etag --output-dir "$DOWNLOAD_LOCATION" -LO "$1"
    cp "$DOWNLOAD_LOCATION/${1##*/}" "./"
}

regedit()
{
    echo "INFO: Adding registry" && "$WINE" regedit "$1" & "$WINE64" regedit "$1" && "$WINESERVER" -w
}

extract()
{
    echo "INFO: Extracting $1" && tar -xf "$1"
}

update()
{
    echo "INFO: Installing ${FUNCNAME[1]}" && DISPLAY="" "$WINE" wineboot && "$WINESERVER" -w
}

installed()
{
    echo "${FUNCNAME[1]}" >> "$WINEPREFIX/rumtricks.log"
    echo "${FUNCNAME[1]} installed"
}

check()
{
    echo "$1  ${FUNCNAME[1]}.tar.zst" | sha256sum -c -
    [ $? -ne 1 ] || { echo "ERROR: Archive is corrupted, skipping" && rm "${FUNCNAME[1]}".tar.zst && return 1; }
}

status()
{
    [[ ! -f "$WINEPREFIX/rumtricks.log" || -z "$(awk "/^${FUNCNAME[1]}\$/ {print \$1}" "$WINEPREFIX/rumtricks.log" 2>/dev/null)" ]] || { echo "${FUNCNAME[1]} already installed, skipping" && return 1; }
}

regsvr32()
{
    echo "INFO: Registering dlls"
    for i in "$@"
    do
    "$WINE" regsvr32 /s "$i" & "$WINE64" regsvr32 /s "$i"
    done
    "$WINESERVER" -w
}

update-self()
{
    echo "INFO: Updating rumtricks"
    download "https://johncena141.eu.org:8141/johncena141/rumtricks/raw/branch/main/rumtricks.sh"
    chmod +x "$PWD/rumtricks.sh"
    [ "$PWD/rumtricks.sh" != "$(realpath "$0")" ] && mv "$PWD/rumtricks.sh" "$(realpath "$0")"
    echo "INFO: Updated rumtricks"
}

isolate()
{
    status || return
    update
    echo "INFO: Disabling desktop integrations (isolation)"
    cd "$WINEPREFIX/drive_c/users/${USER}" || exit
    for entry in *
    do
        if [ -L "$entry" ] && [ -d "$entry" ]
        then
            rm -f "$entry"
            mkdir -p "$entry"
        fi
    done
    rm -rf "$PWD/AppData/Roaming/Microsoft/Windows/Templates"
    mkdir -p "$PWD/AppData/Roaming/Microsoft/Windows/Templates"
    cd "$OLDPWD" || exit
    installed
}

directx()
{
    status || return
    update
    [ ! -f "directx.tar.zst" ] && download "$BASE_URL/directx.tar.zst"
    check 1e5c94ab1a4546ecc0281bc0c491178d77650cb2fc59460f03ebd5762af0d9f6 || return
    extract directx.tar.zst
    cp -r "$PWD"/directx/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/directx/directx.reg
    regsvr32 xactengine2_0.dll xactengine2_1.dll xactengine2_2.dll xactengine2_3.dll xactengine2_4.dll xactengine2_5.dll xactengine2_6.dll xactengine2_7.dll xactengine2_8.dll xactengine2_9.dll xactengine2_10.dll
    regsvr32 xactengine3_0.dll xactengine3_1.dll xactengine3_2.dll xactengine3_3.dll xactengine3_4.dll xactengine3_5.dll xactengine3_6.dll xactengine3_7.dll
    regsvr32 xaudio2_0.dll xaudio2_1.dll xaudio2_2.dll xaudio2_3.dll xaudio2_4.dll xaudio2_5.dll xaudio2_6.dll xaudio2_7.dll
    rm -rf "$PWD"/directx
    installed
}

vcrun2003()
{
    status || return
    update
    [ ! -f "vcrun2003.tar.zst" ] && download "$BASE_URL/vcrun2003.tar.zst"
    check 6af8efa5829b489b70a72b0e13510e9a1e3f92e700fca6d27140483d15364244 || return
    extract vcrun2003.tar.zst
    cp -r "$PWD"/vcrun2003/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    rm -rf "$PWD"/vcrun2003
    installed
}

vcrun2005()
{
    status || return
    update
    [ ! -f "vcrun2005.tar.zst" ] && download "$BASE_URL/vcrun2005.tar.zst"
    check 8d365bd38ddf341cec4f93b6a89027fe3d7065797e6062aa7b5b5cad7ef98099 || return
    extract vcrun2005.tar.zst
    cp -r "$PWD"/vcrun2005/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/vcrun2005/vcrun2005.reg
    rm -rf "$PWD"/vcrun2005
    installed
}

vcrun2008()
{
    status || return
    update
    [ ! -f "vcrun2008.tar.zst" ] && download "$BASE_URL/vcrun2008.tar.zst"
    check 38cf9eb253324ef27ccf3b4e47e3281287acf9e1db48a19bc21c226d53cf8299 || return
    extract vcrun2008.tar.zst
    cp -r "$PWD"/vcrun2008/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/vcrun2008/vcrun2008.reg
    rm -rf "$PWD"/vcrun2008
    installed
}

vcrun2010()
{
    status || return
    update
    [ ! -f "vcrun2010.tar.zst" ] && download "$BASE_URL/vcrun2010.tar.zst"
    check 5ba7ffed884cb25ef77f9f2470a85a31743f79ca1610b6d7cbeda31ce0ac3a35 || return
    extract vcrun2010.tar.zst
    cp -r "$PWD"/vcrun2010/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2010/vcrun2010.reg
    rm -rf "$PWD"/vcrun2010
    installed
}

vcrun2012()
{
    status || return
    update
    [ ! -f "vcrun2012.tar.zst" ] && download "$BASE_URL/vcrun2012.tar.zst"
    check 561716aaee554ab34eb79111c6a0e1aeff6394d0d534450a25c34d8e30609640 || return
    extract vcrun2012.tar.zst
    cp -r "$PWD"/vcrun2012/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2012/vcrun2012.reg
    rm -rf "$PWD"/vcrun2012
    installed
}

vcrun2013()
{
    status || return
    update
    [ ! -f "vcrun2013.tar.zst" ] && download "$BASE_URL/vcrun2013.tar.zst"
    check a9e4a474a433b03feaf1f520d3941d2a5946b07b7700fd3a22dff025b883997d || return
    extract vcrun2013.tar.zst
    cp -r "$PWD"/vcrun2013/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2013/vcrun2013.reg
    rm -rf "$PWD"/vcrun2013
    installed
}

vcrun2015()
{
    status || return
    update
    [ ! -f "vcrun2015.tar.zst" ] && download "$BASE_URL/vcrun2015.tar.zst"
    check 51c9364e4791d7dddcba8fc01cfba1e8dd25da40d8df86b9c012446b573ffd5a || return
    extract "vcrun2015.tar.zst"
    cp -r "$PWD"/vcrun2015/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2015/vcrun2015.reg
    rm -rf "$PWD"/vcrun2015
    installed
}

vcrun2017()
{
    status || return
    update
    [ ! -f "vcrun2017.tar.zst" ] && download "$BASE_URL/vcrun2017.tar.zst"
    check b76a4ac0a4231594816aad58f676ee68da12d0e7ef47e2fdd1ce1e4249ddc5df || return
    extract vcrun2017.tar.zst
    cp -r "$PWD"/vcrun2017/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2017/vcrun2017.reg
    rm -rf "$PWD"/vcrun2017
    installed
}

vcrun2019()
{
    status || return
    update
    [ ! -f "vcrun2019.tar.zst" ] && download "$BASE_URL/vcrun2019.tar.zst"
    check 0a04b662319a9344f42efc70168990b0085b9e42fea43568ab224b73b2ca08bb || return
    extract vcrun2019.tar.zst
    cp -r "$PWD"/vcrun2019/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2019/vcrun2019.reg
    rm -rf "$PWD"/vcrun2019
    installed
}

mf()
{
    status || return
    update
    [ ! -f "mf.tar.zst" ] && download "$BASE_URL/mf.tar.zst"
    check 42612d19396d791576de9e56ca30de5ae0cd5afd0ba2ac9d411347a2efe5114c || return
    extract "mf.tar.zst"
    cp -r "$PWD"/mf/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/mf/mf.reg
    regsvr32 colorcnv.dll msmpeg2adec.dll msmpeg2vdec.dll
    rm -rf "$PWD"/mf
    installed
}

vdesktop()
{
    [ ! -f rres ] && curl -L "$(curl -s https://api.github.com/repos/rokbma/rres/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')" -o rres && chmod +x rres
    echo "explorer /desktop=Game,$(./rres)"
}

vdesktop-d()
{
    [ ! -f "$PWD"/vdesktop-d.reg ] && printf 'Windows Registry Editor Version 5.00\n\n[HKEY_CURRENT_USER\Software\Wine\\Explorer]\n"Desktop"=-\n[HKEY_CURRENT_USER\Software\Wine\\Explorer\Desktops]\n"Default"=-' > vdesktop-d.reg
    "$WINE" regedit vdesktop-d.reg
    rm vdesktop-d.reg
}

physx()
{
    status || return
    update
    [ ! -f "physx.tar.zst" ] && download "$BASE_URL/physx.tar.zst"
    check eb275e31687173f3accada30c0c8af6456977ac94b52a0fdd17cbbdd5d68f488 || return
    extract physx.tar.zst
    cp -r "$PWD"/physx/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/physx/physx.reg
    rm -rf "$PWD"/physx
    installed
}

github_dxvk()
{
    DL_URL="$(curl -s https://api.github.com/repos/doitsujin/dxvk/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
    DXVK="$(basename "$DL_URL")"
    [ ! -f "$DXVK" ] && download "$DL_URL"
    extract "$DXVK" || { rm "$DXVK" && echo "ERROR: Failed to extract dxvk, skipping" && return 1; }
    cd "${DXVK//.tar.gz/}" || exit
    DISPLAY="" ./setup_dxvk.sh install && "$WINESERVER" -w
    cd "$OLDPWD" || exit
    rm -rf "${DXVK//.tar.gz/}"
}

dxvk()
{
    DXVKVER="$(curl -s -m 5 https://api.github.com/repos/doitsujin/dxvk/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}' | cut -c 2-)"; SYSDXVK="$(command -v setup_dxvk 2>/dev/null)"
    dxvk() {
        update
        [ -n "$SYSDXVK" ] && echo "INFO: Using local dxvk" && DISPLAY="" "$SYSDXVK" install --symlink && "$WINESERVER" -w && installed
        [ -z "$SYSDXVK" ] && echo "INFO: Using dxvk from github" && github_dxvk && echo "$DXVKVER" > "$WINEPREFIX/.dxvk"
    }
    [[ ! -f "$WINEPREFIX/.dxvk" && -z "$(status)" ]] && dxvk
    [[ -f "$WINEPREFIX/.dxvk" && -n "$DXVKVER" && "$DXVKVER" != "$(awk '{print $1}' "$WINEPREFIX/.dxvk")" ]] && { rm -f dxvk-*.tar.gz || true; } && echo "updating dxvk" && dxvk
    echo "INFO: dxvk is up-to-date"
}

dxvk-async()
{
    DXVKVER="$(curl -s -m 5 https://api.github.com/repos/Sporif/dxvk-async/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}')"
    dxvk-async() {
        update
        DL_URL="$(curl -s https://api.github.com/repos/Sporif/dxvk-async/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
        DXVK="$(basename "$DL_URL")"
        [ ! -f "$DXVK" ] && download "$DL_URL"
        extract "$DXVK" || { rm "$DXVK" && echo "ERROR: Failed to extract dxvk, skipping" && return 1; }
        cd "${DXVK//.tar.gz/}" || exit
        chmod +x ./setup_dxvk.sh && DISPLAY="" ./setup_dxvk.sh install && "$WINESERVER" -w
        cd "$OLDPWD" || exit
        rm -rf "${DXVK//.tar.gz/}"
        installed ; echo "$DXVKVER" > "$WINEPREFIX/.dxvk-async"
    }
    [[ -z "$(status)" ]] && dxvk-async
    [[ -f "$WINEPREFIX/.dxvk-async" && -n "$DXVKVER" && "$DXVKVER" != "$(awk '{print $1}' "$WINEPREFIX/.dxvk-async")" ]] && { rm -f dxvk-async-*.tar.gz || true; } && echo "updating dxvk-async" && dxvk-async
    echo "INFO: dxvk-async is up-to-date"
}

dxvk-custom()
{
    status || return
    update
    read -r -p "What version do you want? (0.54, 1.8.1, etc.): " DXVKVER
    DL_URL="https://github.com/doitsujin/dxvk/releases/download/v$DXVKVER/dxvk-$DXVKVER.tar.gz"
    DXVK="$(basename "$DL_URL")"
    [ ! -f "$DXVK" ] && download "$DL_URL"
    extract "$DXVK" || { rm "$DXVK" && echo "ERROR: Failed to extract dxvk-custom, skipping" && return 1; }
    cd "${DXVK//.tar.gz/}" || exit
    [ -f setup_dxvk.sh ] && DISPLAY="" ./setup_dxvk.sh install && "$WINESERVER" -w
    [ ! -f setup_dxvk.sh ] && cd x32 && ./setup_dxvk.sh && "$WINESERVER" -w && cd ..
    [ ! -f setup_dxvk.sh ] && [ "$WINEARCH" = "win64" ] && cd x64 && ./setup_dxvk.sh && "$WINESERVER" -w && cd ..
    cd ..
    rm -rf "${DXVK//.tar.gz/}"
    installed
}

wmp11()
{
    status || return
    mf
    update
    [ ! -f "wmp11.tar.zst" ] && download "$BASE_URL/wmp11.tar.zst"
    check 7e68b15655c450a1912e0d5f1fc21c66ee2037d676da1949c6ee93a00d792a3c || return
    extract wmp11.tar.zst
    cp -r "$PWD"/wmp11/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/wmp11/wmp11.reg
    regsvr32 dispex.dll jscript.dll scrobj.dll scrrun.dll vbscript.dll wshcon.dll wshext.dll
    rm -rf "$PWD"/wmp11
    installed
}

mono()
{
    MONOVER="$(curl -s https://api.github.com/repos/madewokherd/wine-mono/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}' | awk -F '[-]' '/.msi/ {print $6}')"
    mono() {
        update
        DL_URL="$(curl -s https://api.github.com/repos/madewokherd/wine-mono/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}' | awk '/msi/ {print $0}')"
        MONO="$(basename "$DL_URL")"
        [ ! -f "$MONO" ] && download "$DL_URL"
        remove-mono
        "$WINE" msiexec /i "$MONO"
        installed ; echo "$MONOVER" > "$WINEPREFIX/.mono"
    }
    [[ -z "$(awk '/mono/ {print $1}' "$WINEPREFIX/rumtricks.log" 2>/dev/null)" ]] && mono
    [[ -f "$WINEPREFIX/.mono" && -n "$MONOVER" && "$MONOVER" != "$(awk '{print $1}' "$WINEPREFIX/.mono")" ]] && { rm -f wine-mono-*.msi || true; } && echo "updating mono" && mono
    echo "INFO: mono is up-to-date"
}

remove-mono()
{
    echo "INFO: Removing mono"
    for i in $("$WINE" uninstaller --list | awk -F '[|]' '/Wine Mono/ {print $1}'); do "$WINE" uninstaller --remove "$i"; done
    echo "INFO: Mono removed"
}

github_vkd3d()
{
    DL_URL="$(curl -s https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
    VKD3D="$(basename "$DL_URL")"
    [ ! -f "$VKD3D" ] && download "$DL_URL"
    extract "$VKD3D" || { rm "$VKD3D" && echo "ERROR: Failed to extract vkd3d, skipping" && return 1; }
    cd "${VKD3D//.tar.zst/}" || exit
    DISPLAY="" ./setup_vkd3d_proton.sh install && "$WINESERVER" -w
    cd "$OLDPWD" || exit
    rm -rf "${VKD3D//.tar.zst/}"
}

vkd3d()
{
    VKD3DVER="$(curl -s -m 5 https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}' | cut -c 2-)"; SYSVKD3D="$(command -v setup_vkd3d_proton)"
    vkd3d() {
        update
        [ -n "$SYSVKD3D" ] && echo "INFO: Using local vkd3d" && DISPLAY="" "$SYSVKD3D" install --symlink && "$WINESERVER" -w && installed
        [ -z "$SYSVKD3D" ] && echo "INFO: Using vkd3d from github" && github_vkd3d && echo "$VKD3DVER" > "$WINEPREFIX/.vkd3d"
    }
    [[ ! -f "$WINEPREFIX/.vkd3d" && -z "$(status)" ]] && vkd3d
    [[ -f "$WINEPREFIX/.vkd3d" && -n "$VKD3DVER" && "$VKD3DVER" != "$(awk '{print $1}' "$WINEPREFIX/.vkd3d")" ]] && { rm -f vkd3d-proton-*.tar.zst || true; } && echo "updating vkd3d" && vkd3d
    echo "INFO: vkd3d is up-to-date"
}

provided_vkd3d()
{
    TARGET="vkd3d-proton-master.tar.zst"
    if [ ! -f "$TARGET" ]; then
        echo "INFO: Downloading latest vkd3d..."
        DL_URL="$(curl -s 'https://johncena141.eu.org:8141/api/v1/repos/johncena141/vkd3d-jc141/releases?draft=false&pre-release=false&limit=1' -H 'accept: application/json' | jq '.[].assets[0].browser_download_url' | awk -F'"' '{print $2}')"
        [ -z "$DL_URL" ] && { echo "ERROR: Couldn't download latest vkd3d"; return 1; }
        curl -L "$DL_URL" -o "$TARGET"
    fi
    extract "$TARGET" || { rm "$TARGET" && echo "ERROR: Failed to extract vkd3d" && return 1; }
    cd "${TARGET//.tar.zst/}" || exit
    DISPLAY="" ./setup_vkd3d_proton.sh install && "$WINESERVER" -w
    cd "$OLDPWD" || exit
    rm -rf "${TARGET//.tar.zst/}"
}

vkd3d-jc141()
{
    read -r -p "Game: " GAME
    [ -z "$GAME" ] && GAME="all"
    USE_GITHUB="$(curl -sL -m 5 "https://johncena141.eu.org:8141/johncena141/vkd3d-jc141/raw/branch/main/use-github/$GAME")"
    [ "$USE_GITHUB" = "true" ] && touch "$WINEPREFIX/.github-vkd3d"
    if [ -f "$WINEPREFIX/.github-vkd3d" ]; then
        vkd3d
    else
        status || return
        update
        provided_vkd3d
        installed
    fi
}

directshow()
{
    status || return
    update
    [ ! -f "directshow.tar.zst" ] && download "$BASE_URL/directshow.tar.zst"
    check 5fb584ca65c8f8fc6b4910210f355c002fa12dfd4186805ef6e7708e41595e32 || return
    extract directshow.tar.zst
    cp -r "$PWD"/directshow/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/directshow/directshow.reg
    regsvr32 amstream.dll qasf.dll qcap.dll qdvd.dll qedit.dll quartz.dll
    rm -rf "$PWD"/directshow
    installed
}

cinepak()
{
    status || return
    update
    [ ! -f "cinepak.tar.zst" ] && download "$BASE_URL/cinepak.tar.zst"
    check fb1daa15378f8a70a90617044691e1c5318610939adc0e79ad365bdb31513a38 || return
    extract cinepak.tar.zst
    cp -r "$PWD"/cinepak/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/cinepak/cinepak.reg
    rm -rf "$PWD"/cinepak
    installed
}

corefonts()
{
    status || return
    update
    [ ! -f "corefonts.tar.zst" ] && download "$BASE_URL/corefonts.tar.zst"
    check fb6a4fffaae3c5ae849c0bb5ebf1ed7649ea521fab171166c35f6068b87dc80f || return
    extract corefonts.tar.zst
    cp -r "$PWD"/corefonts/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/corefonts/corefonts.reg
    rm -rf "$PWD"/corefonts
    installed
}

quicktime()
{
    status || return
    update
    [ ! -f "quicktime.tar.zst" ] && download "$BASE_URL/quicktime.tar.zst"
    check 5adc5d05c94339d17814cb1a831c994e2b14ba9fbda0339d2add19c856f483a6 || return
    extract quicktime.tar.zst
    cp -r "$PWD"/quicktime/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/quicktime/quicktime.reg
    rm -rf "$PWD"/quicktime
    installed
}

directplay()
{
    status || return
    update
    [ ! -f "directplay.tar.zst" ] && download "$BASE_URL/directplay.tar.zst"
    check 8e4c467685011ac0818b99333061758f69cc5f0bd0680b83a507c8a6765c79fd || return
    extract directplay.tar.zst
    cp -r "$PWD"/directplay/files/drive_c/windows/syswow64/* "$WINEPREFIX/drive_c/windows/syswow64"
    regedit "$PWD"/directplay/directplay.reg
    regsvr32 dplayx.dll dpnet.dll dpnhpast.dll dpnhupnp.dll
    rm -rf "$PWD"/directplay
    installed
}

dotnet35()
{
    status || return
    remove-mono
    update
    [ ! -f "dotnet35.tar.zst" ] && download "$BASE_URL/dotnet35.tar.zst"
    check 146f567c0b4ee080600d2cd7343238058e28008fc0c7d80d968da8611e63563a || return
    extract dotnet35.tar.zst
    cp -r "$PWD"/dotnet35/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/dotnet35/dotnet35.reg
    rm -rf "$PWD/dotnet35"
    installed
}

template()
{
    #update
    #[ ! -f "template.tar.zst" ] && download "$BASE_URL/template.tar.zst"
    #check 2bcf9852b02f6e707905f0be0a96542225814a3fc19b3b9dcf066f4dd2781337
    #[ $? -eq 1 ] && echo "ERROR: Download is corrupted (invalid hash), skipping" && rm template.tar.zst && return
    #extract template.tar.zst
    #cp -r "$PWD"/template/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    #regedit "$PWD"/template/template.reg
    #echo "template" >> "$WINEPREFIX/rumtricks.log"
    #rm -rf "$PWD"/template
    installed
}

win10()
{
    status || return
    update
    "$WINE" winecfg -v win10
    installed
}

win81()
{
    status || return
    update
    "$WINE" winecfg -v win81
    installed
}

win8()
{
    status || return
    update
    "$WINE" winecfg -v win8
    installed
}

win2008r2()
{
    status || return
    update
    "$WINE" winecfg -v win2008r2
    installed
}

win2008()
{
    status || return
    update
    "$WINE" winecfg -v win2008
    installed
}

win7()
{
    status || return
    update
    "$WINE" winecfg -v win7
    installed
}

winvista()
{
    status || return
    update
    "$WINE" winecfg -v vista
    installed
}

win2003()
{
    status || return
    update
    "$WINE" winecfg -v win2003
    installed
}

winxp()
{
    status || return
    update
    [ "$WINEARCH" = "win64" ] && "$WINE" winecfg -v winxp64
    [ "$WINEARCH" = "win32" ] && "$WINE" winecfg -v winxp
    installed
}

win2k()
{
    status || return
    update
    "$WINE" winecfg -v win2k
    installed
}

winme()
{
    status || return
    update
    "$WINE" winecfg -v winme
    installed
}

win98()
{
    status || return
    update
    "$WINE" winecfg -v win98
    installed
}

win95()
{
    status || return
    update
    "$WINE" winecfg -v win95
    installed
}

win98()
{
    status || return
    update
    "$WINE" winecfg -v win98
    installed
}

winnt40()
{
    status || return
    update
    "$WINE" winecfg -v nt40
    installed
}

winnt351()
{
    status || return
    update
    "$WINE" winecfg -v nt351
    installed
}

win31()
{
    status || return
    update
    "$WINE" winecfg -v win31
    installed
}

win30()
{
    status || return
    update
    "$WINE" winecfg -v win30
    installed
}

win20()
{
    status || return
    update
    "$WINE" winecfg -v win20
    installed
}

check_connectivity() {
    local test_ip
    local test_count

    test_ip="johncena141.eu.org"
    test_count=1

    if ping -c ${test_count} ${test_ip} > /dev/null; then
       echo "INFO: Internet connectivity present"
    else
       echo "INFO: Internet connectivity not present" && exit 1
    fi
}

wine-jc141()
{
check_connectivity
JQ="$(command -v jq)"; [ ! -x "$JQ" ] && exit 1 && echo "ERROR: jq not found, skipping updates. (read the requirements guide)" || echo "INFO: jq found"
WINEJC="groot"; VERSION_FILE="$PWD/.wine-jc141-current-version"
latest_release="$(curl -s https://johncena141.eu.org:8141/api/v1/repos/johncena141/wine-jc141/releases?limit=1)"
tag_name=$(echo "$latest_release" | jq -r  '[.[].tag_name][0]')
update=1
if [ -f "$VERSION_FILE" ]; then
   version=$(cat "$VERSION_FILE")
   if [ "$tag_name" = "$version" ]; then
   echo "INFO: You have the latest wine version ($version)."
   update=0
   else
   echo "INFO: New version found! Updating.."
  fi
fi
if [ "$update" -eq "1" ]; then
    download_url=$(echo "$latest_release" | jq -r  '[.[].assets[0].browser_download_url][0]')
    if [ "$download_url" = "null" ]; then
        echo "ERROR: Could not find the download URL. Abort"
        exit 1
    fi
    echo "$tag_name" > "$VERSION_FILE" && echo "INFO: Downloading... $download_url"
    DOWNLOAD_FILE=wine.tar.zst && rm -f "$DOWNLOAD_FILE"
    [ ! -f "$WINEJC/$DOWNLOAD_FILE" ] && wget -O "$DOWNLOAD_FILE" "$download_url"
    [ -d "$WINEJC/wine-backup" ] && mv "$WINEJC/wine-backup" "$WINEJC/wine-old"
    [ -d "$WINEJC/wine" ] && mv "$WINEJC/wine" "$WINEJC/wine-backup"
    echo "INFO: Extracting wine-jc141" && tar -xvf "$DOWNLOAD_FILE" && mv "$PWD/wine" "$WINEJC/wine" && rm -rf "$WINEJC/wine-old" && rm -f "$WINEJC/$DOWNLOAD_FILE"
fi
}

# Running rumtricks
[ $# = 0 ] && echo "INFO: Add rumtricks" && exit 1
for i in "$@"
do
   "$i"
done
