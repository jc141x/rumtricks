#!/bin/bash

#TODO
# code clean up
# allow rumtricks to manage auto updating dxvk and vkd3d 

##########

# Forbid root rights
[ "$EUID" = "0" ] && echo -e "\e[91mDon't use sudo or root user to execute rumtricks!\e[0m" && exit

# All operations are relative to rumtricks' location
cd "$(dirname "$(realpath "$0")")" || exit 1

# Base download URL for the archive
BASE_URL="https://github.com/goldenboy313/rumtricks/raw/main/archives"

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
    command -v aria2c >/dev/null 2>&1 && aria2c --allow-overwrite="true" "$1" && return
    command -v wget >/dev/null 2>&1 && wget -N "$1" && return
    command -v curl >/dev/null 2>&1 && curl -LO "$1" && return
}

regedit()
{
    echo "adding registry" && "$WINE" regedit "$1" && "$WINE64" regedit "$1" && "$WINESERVER" -w
}

extract()
{
    echo "extracting $1" && tar -xf "$1"
}

update()
{
    echo "installing ${FUNCNAME[1]}" && "$WINE" wineboot -u && "$WINESERVER" -w
}

installed()
{
    echo "${FUNCNAME[1]} installed"
}

check()
{   
    echo "$1  ${FUNCNAME[1]}.tar.zst" | sha256sum -c -
}

register_dll()
{
    for i in "$@"
    do
    "$WINE" regsvr32 "$i" && "$WINE64" regsvr32 "$i"
    done
}

update-self()
{
    echo "updating rumtricks"
    download "https://github.com/goldenboy313/rumtricks/raw/main/rumtricks.sh"
    chmod +x "$PWD/rumtricks.sh"
    [ "$PWD/rumtricks.sh" != "$(realpath "$0")" ] && mv "$PWD/rumtricks.sh" "$(realpath "$0")"
    echo "done"
}

isolate()
{
    update
    echo "disabling desktop integrations"
    cd "$WINEPREFIX/drive_c/users/${USER}" || exit
    for entry in *
    do
        if [ -L "$entry" ] && [ -d "$entry" ]
        then
            rm -f "$entry"
            mkdir -p "$entry"
        fi
    done
    cd "$OLDPWD" || exit
    echo "isolate" >> "$WINEPREFIX/rumtricks.log"
    installed
}

directx()
{
    update
    [ ! -f "directx.tar.zst" ] && download "$BASE_URL/directx.tar.zst"
    check 1e5c94ab1a4546ecc0281bc0c491178d77650cb2fc59460f03ebd5762af0d9f6
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm directx.tar.zst && return
    extract directx.tar.zst
    cp -r "$PWD"/directx/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/directx/directx.reg
    register_dll xactengine2_0.dll xactengine2_1.dll xactengine2_2.dll xactengine2_3.dll xactengine2_4.dll xactengine2_5.dll xactengine2_6.dll xactengine2_7.dll xactengine2_8.dll xactengine2_9.dll xactengine2_10.dll 
    register_dll xactengine3_0.dll xactengine3_1.dll xactengine3_2.dll xactengine3_3.dll xactengine3_4.dll xactengine3_5.dll xactengine3_6.dll xactengine3_7.dll
    register_dll xaudio2_0.dll xaudio2_1.dll xaudio2_2.dll xaudio2_3.dll xaudio2_4.dll xaudio2_5.dll xaudio2_6.dll xaudio2_7.dll
    echo "directx" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/directx
    installed
}

vcrun2010()
{
    update
    [ ! -f "vcrun2010.tar.zst" ] && download "$BASE_URL/vcrun2010.tar.zst"
    check bb58b714c95373f4ad2d3757d27658c6ce37de5fa4cbc85c16e5ca01178fb883
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm vcrun2010.tar.zst && return
    extract vcrun2010.tar.zst
    cp -r "$PWD"/vcrun2010/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2010/vcrun2010.reg
    echo "vcrun2010" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/vcrun2010
    installed
}

vcrun2012()
{
    update
    [ ! -f "vcrun2012.tar.zst" ] && download "$BASE_URL/vcrun2012.tar.zst"
    check 6ff3e8896d645c76ec8ef9a7fee613aea0a6b06fad04a35ca8a1fb7a4a314ce6
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm vcrun2012.tar.zst && return
    extract vcrun2012.tar.zst
    cp -r "$PWD"/vcrun2012/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2012/vcrun2012.reg
    echo "vcrun2012" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/vcrun2012
    installed
}

vcrun2013()
{
    update
    [ ! -f "vcrun2013.tar.zst" ] && download "$BASE_URL/vcrun2013.tar.zst"
    check b9c990f6440e31b8b53ad80e1f1b524a4accadea2bdcfa7f2bddb36c40632610
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm vcrun2013.tar.zst && return
    extract vcrun2013.tar.zst
    cp -r "$PWD"/vcrun2013/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2013/vcrun2013.reg
    echo "vcrun2013" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/vcrun2013
    installed
}

vcrun2015()
{
    update
    [ ! -f "vcrun2015.tar.zst" ] && download "$BASE_URL/vcrun2015.tar.zst"
    check 2b0bc92d4bd2a48f7e4d0a958d663baa5f3165eab95521e71f812b9030b03eb6
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm vcrun2015.tar.zst && return
    extract "vcrun2015.tar.zst"
    cp -r "$PWD"/vcrun2015/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2015/vcrun2015.reg
    echo "vcrun2015" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/vcrun2015
    installed
}

vcrun2017()
{
    update
    [ ! -f "vcrun2017.tar.zst" ] && download "$BASE_URL/vcrun2017.tar.zst"
    check 2bcf9852b02f6e707905f0be0a96542225814a3fc19b3b9dcf066f4dd2789773
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm vcrun2017.tar.zst && return
    extract vcrun2017.tar.zst
    cp -r "$PWD"/vcrun2017/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2017/vcrun2017.reg
    echo "vcrun2017" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/vcrun2017
    installed
}

vcrun2019()
{
    update
    [ ! -f "vcrun2019.tar.zst" ] && download "$BASE_URL/vcrun2019.tar.zst"
    check f84542198789d35db77ba4bc73990a2122d97546db5aca635b3058fc1830961d
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm vcrun2019.tar.zst && return
    extract vcrun2019.tar.zst
    cp -r "$PWD"/vcrun2019/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/vcrun2019/vcrun2019.reg
    echo "vcrun2019" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/vcrun2019
    installed
}

mf()
{
    update
    [ ! -f "mf.tar.zst" ] && download "$BASE_URL/mf.tar.zst"
    check 42612d19396d791576de9e56ca30de5ae0cd5afd0ba2ac9d411347a2efe5114c
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm mf.tar.zst && return
    extract "mf.tar.zst"
    cp -r "$PWD"/mf/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/mf/mf.reg
    register_dll colorcnv.dll msmpeg2adec.dll msmpeg2vdec.dll
    echo "mf" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/mf
    installed
}

vdesktop()
{
    [ ! -f rres ] && curl -L "$(curl -s https://api.github.com/repos/rokbma/rres/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')" -o rres && chmod +x rres
    echo "explorer /desktop=Game,$(./rres)"
}

physx()
{
    update
    [ ! -f "physx.tar.zst" ] && download "$BASE_URL/physx.tar.zst"
    check eb275e31687173f3accada30c0c8af6456977ac94b52a0fdd17cbbdd5d68f488
    [ $? -eq 1 ] && echo "archive is corrupted (invalid hash), skipping" && rm physx.tar.zst && return
    extract physx.tar.zst
    cp -r "$PWD"/physx/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/physx/physx.reg
    echo "physx" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/physx
    installed
}

dxvk()
{
    update
    DL_URL="$(curl -s https://api.github.com/repos/doitsujin/dxvk/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
    DXVK="$(basename "$DL_URL")"
    [ ! -f "$DXVK" ] && download "$DL_URL"
    extract "$DXVK" || { rm "$DXVK" && echo "failed to extract dxvk, skipping" && return 1; }
    cd "${DXVK//.tar.gz/}" || exit
    ./setup_dxvk.sh install
    cd "$OLDPWD" || exit
    echo "dxvk" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "${DXVK//.tar.gz/}"
    installed
}

wmp11()
{
    mf
    update
    [ ! -f "wmp11.tar.zst" ] && download "$BASE_URL/wmp11.tar.zst"
    check 7e68b15655c450a1912e0d5f1fc21c66ee2037d676da1949c6ee93a00d792a3c
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm wmp11.tar.zst && return
    extract wmp11.tar.zst
    cp -r "$PWD"/wmp11/files/drive_c/* "$WINEPREFIX/drive_c/"
    regedit "$PWD"/wmp11/wmp11.reg
    register_dll dispex.dll jscript.dll scrobj.dll scrrun.dll vbscript.dll wshcon.dll wshext.dll
    echo "wmp11" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/wmp11
    installed
}

mono()
{
    update
    DL_URL="$(curl -s https://api.github.com/repos/madewokherd/wine-mono/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}' | awk '/msi/ {print $0}')"
    MONO="$(basename "$DL_URL")"
    OLDMONO="$("$WINE" uninstaller --list | grep 'Wine Mono' | cut -f1 -d\|)"
    [ ! -f "$MONO" ] && download "$DL_URL"
    [ -n "$OLDMONO" ] && echo "removing old mono" && for i in $OLDMONO; do "$WINE" uninstaller --remove "$i"; done
    "$WINE" msiexec /i "$MONO"
    echo "mono" >> "$WINEPREFIX/rumtricks.log"
    installed
}

vkd3d()
{
    update
    DL_URL="$(curl -s https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
    VKD3D="$(basename "$DL_URL")"
    [ ! -f "$VKD3D" ] && download "$DL_URL"
    extract "$VKD3D" || { rm "$DXVK" && echo "failed to extract vkd3d, skipping" && return 1; }
    cd "${VKD3D//.tar.zst/}" || exit
    ./setup_vkd3d_proton.sh install
    cd "$OLDPWD" || exit
    echo "vkd3d" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "${VKD3D//.tar.zst/}"
    installed
}

directshow()
{
    update
    [ ! -f "directshow.tar.zst" ] && download "$BASE_URL/directshow.tar.zst"
    check 5fb584ca65c8f8fc6b4910210f355c002fa12dfd4186805ef6e7708e41595e32
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm directshow.tar.zst && return
    extract directshow.tar.zst
    cp -r "$PWD"/directshow/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/directshow/directshow.reg
    register_dll amstream.dll qasf.dll qcap.dll qdvd.dll qedit.dll quartz.dll
    echo "directshow" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/directshow
    installed
}

cinepak()
{
    update
    [ ! -f "cinepak.tar.zst" ] && download "$BASE_URL/cinepak.tar.zst"
    check fb1daa15378f8a70a90617044691e1c5318610939adc0e79ad365bdb31513a38
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm cinepak.tar.zst && return
    extract cinepak.tar.zst
    cp -r "$PWD"/cinepak/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/cinepak/cinepak.reg
    echo "cinepak" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/cinepak
    installed
}

corefonts()
{
    update
    [ ! -f "corefonts.tar.zst" ] && download "$BASE_URL/corefonts.tar.zst"
    check fb6a4fffaae3c5ae849c0bb5ebf1ed7649ea521fab171166c35f6068b87dc80f
    [ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm corefonts.tar.zst && return
    extract corefonts.tar.zst
    cp -r "$PWD"/corefonts/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    regedit "$PWD"/corefonts/corefonts.reg
    echo "corefonts" >> "$WINEPREFIX/rumtricks.log"
    rm -rf "$PWD"/corefonts
    installed
}

template()
{
    #update
    #[ ! -f "template.tar.zst" ] && download "$BASE_URL/template.tar.zst"
    #check 2bcf9852b02f6e707905f0be0a96542225814a3fc19b3b9dcf066f4dd2781337
    #[ $? -eq 1 ] && echo "download is corrupted (invalid hash), skipping" && rm template.tar.zst && return
    #extract template.tar.zst
    #cp -r "$PWD"/template/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"
    #regedit "$PWD"/template/template.reg
    #echo "template" >> "$WINEPREFIX/rumtricks.log"
    #rm -rf "$PWD"/template
    installed
}

# Running rumtricks
[ $# = 0 ] && echo "add rumtricks" && exit 1
for i in "$@"
do
   "$i"
done
