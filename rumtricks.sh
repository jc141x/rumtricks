#!/bin/bash
[ "$EUID" = "0" ] && exit
# All operations are relative to rumtricks' location
cd "$(dirname "$(realpath "$0")")" || exit 1
RMTDIR="${XDG_DATA_HOME:-$HOME/.local/share}/rumtricks"; RMTCONTENT="$RMTDIR/rumtricks-content"
[ -z "$WINEARCH" ] && export WINEARCH="win64"; [ -z "$WINEPREFIX" ] && export WINEPREFIX="$HOME/.wine"
export RUMTRICKS_LOGFILE="$WINEPREFIX/rumtricks.log"
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"; export WINEDEBUG="-all"
DOWNLOAD_LOCATION="${XDG_CACHE_HOME:-$HOME/.cache}/rumtricks"; mkdir -p "$DOWNLOAD_LOCATION"

# Support custom Wine versions
[ -z "$WINE" ] && export WINE="$(command -v wine)"; [ ! -x "$WINE" ] && echo "${WINE} is not an executable, exiting." && exit 1
[ -z "$WINE64" ] && export WINE64="${WINE}64"; [ ! -x "$WINE64" ] && echo "${WINE64} is not an executable, exiting." && exit 1
[ -z "$WINESERVER" ] && export WINESERVER="${WINE}server"; [ ! -x "$WINESERVER" ] && echo "${WINESERVER} is not an executable, exiting." && exit 1

# blame dxvk I guess?
wine() { "$WINE" $@; }; wine64() { "$WINE64" $@; }; wineboot() { "$WINEBOOT" $@; }
export -f wine wine64 wineboot

update() { echo -n "RMT: Applying ${FUNCNAME[1]}. | " && "$WINE" wineboot && "$WINESERVER" -w; }
regedit() { echo -n "RMT: Adding registry. | " && "$WINE" regedit "$1" & "$WINE64" regedit "$1" && "$WINESERVER" -w; }
extract() { echo -n "RMT: Extracting $1. | " && tar -xvf "$1" &>/dev/null; }
applied() { echo "${FUNCNAME[1]}" >>"$RUMTRICKS_LOGFILE"; echo -n "RMT: ${FUNCNAME[1]} applied. | "; }
status() { [[ ! -f "$RUMTRICKS_LOGFILE" || -z "$(awk "/^${FUNCNAME[1]}\$/ {print \$1}" "$RUMTRICKS_LOGFILE" 2>/dev/null)" ]] || { echo -n "RMT: ${FUNCNAME[1]} present. | " && return 1; }; }
download() { cd "$DOWNLOAD_LOCATION"; command -v curl >/dev/null 2>&1 && curl --etag-save $DOWNLOAD_LOCATION/${1##*/}.etag --etag-compare $DOWNLOAD_LOCATION/${1##*/}.etag -LO "$1"; cd "$OLDPWD"; cp "$DOWNLOAD_LOCATION/${1##*/}" "./"; }
regsvr32() { echo -n "RMT: Registering DLLs. | "
for i in "$@"; do
"$WINE" regsvr32 /s "$i" &
"$WINE64" regsvr32 /s "$i"
done
"$WINESERVER" -w; }

isolation() { status || return; update
    cd "$WINEPREFIX/drive_c/users/${USER}" || exit
    for entry in *; do
        if [ -L "$entry" ] && [ -d "$entry" ]; then
            rm -f "$entry"
            mkdir -p "$entry"
        fi
    done
rm -rf "$PWD/AppData/Roaming/Microsoft/Windows/Templates"; mkdir -p "$PWD/AppData/Roaming/Microsoft/Windows/Templates"; cd "$OLDPWD" || exit; applied; }

github_dxvk() { DL_URL="$(curl -s https://api.github.com/repos/jc141x/dxvk/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"; DXVK="$(basename "$DL_URL")"
[ ! -f "$DXVK" ] && download "$DL_URL"; extract "$DXVK" || { rm "$DXVK" && echo "RMT-ERROR: Failed to extract dxvk, skipping." && return 1; }
cd "${DXVK//.tar.gz/}" || exit; ./setup_dxvk.sh install > /dev/null && "$WINESERVER" -w; cd "$OLDPWD" || exit; rm -rf "${DXVK//.tar.gz/}"; }

dxvk() { DXVKVER="$(curl -s -m 5 https://api.github.com/repos/jc141x/dxvk/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}' | cut -c 2-)"; SYSDXVK="$(command -v setup_dxvk 2>/dev/null)"
    dxvk() { update
    [ -n "$SYSDXVK" ] && echo -n "RMT: Using local dxvk. | " && "$SYSDXVK" install --symlink > /dev/null && "$WINESERVER" -w && applied
    [ -z "$SYSDXVK" ] && echo -n "RMT: Using dxvk from github. | " && github_dxvk && echo "$DXVKVER" >"$WINEPREFIX/.dxvk"; }
    [[ ! -f "$WINEPREFIX/.dxvk" && -z "$(status)" ]] && dxvk
    [[ -f "$WINEPREFIX/.dxvk" && -n "$DXVKVER" && "$DXVKVER" != "$(awk '{print $1}' "$WINEPREFIX/.dxvk")" ]] && { rm -f dxvk-*.tar.gz || true; } && echo -n "RMT: Updating dxvk. | " && dxvk
echo -n "RMT: dxvk is up-to-date. | "; }

dxvk-async() { DXVKVER="$(curl -s -m 5 https://api.github.com/repos/Sporif/dxvk-async/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}')"
    dxvk-async() { update
    DL_URL="$(curl -s https://api.github.com/repos/Sporif/dxvk-async/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
    DXVK="$(basename "$DL_URL")"
    [ ! -f "$DXVK" ] && download "$DL_URL"
    extract "$DXVK" || { rm "$DXVK" && echo "RMT-ERROR: Failed to extract dxvk, skipping." && return 1; }
    cd "${DXVK//.tar.gz/}" || exit
    chmod +x ./setup_dxvk.sh && ./setup_dxvk.sh install && "$WINESERVER" -w
    cd "$OLDPWD" || exit; rm -rf "${DXVK//.tar.gz/}"; applied; echo "$DXVKVER" >"$WINEPREFIX/.dxvk-async";}
[[ -z "$(status)" ]] && dxvk-async
[[ -f "$WINEPREFIX/.dxvk-async" && -n "$DXVKVER" && "$DXVKVER" != "$(awk '{print $1}' "$WINEPREFIX/.dxvk-async")" ]] && { rm -f dxvk-async-*.tar.gz || true; } && echo -n "RMT: Updating dxvk-async. | " && dxvk-async
echo -n "RMT: dxvk-async is up-to-date. | "; }

dxvk-custom() { status || return; update
    read -r -p "What version do you want? (0.54, 1.8.1, etc.): " DXVKVER
    DL_URL="https://github.com/doitsujin/dxvk/releases/download/v$DXVKVER/dxvk-$DXVKVER.tar.gz"
    DXVK="$(basename "$DL_URL")"
    [ ! -f "$DXVK" ] && download "$DL_URL"
    extract "$DXVK" || { rm "$DXVK" && echo "ERROR: Failed to extract dxvk-custom, skipping." && return 1; }
    cd "${DXVK//.tar.gz/}" || exit
    [ -f setup_dxvk.sh ] && ./setup_dxvk.sh install && "$WINESERVER" -w
    [ ! -f setup_dxvk.sh ] && cd x32 && ./setup_dxvk.sh && "$WINESERVER" -w && cd ..
    [ ! -f setup_dxvk.sh ] && [ "$WINEARCH" = "win64" ] && cd x64 && ./setup_dxvk.sh && "$WINESERVER" -w && cd ..
    cd ..; rm -rf "${DXVK//.tar.gz/}"; applied; }

github_vkd3d() { DL_URL="$(curl -s https://api.github.com/repos/jc141x/vkd3d-proton/releases/latest | awk -F '["]' '/"browser_download_url":/ {print $4}')"
    VKD3D="$(basename "$DL_URL")"
    [ ! -f "$VKD3D" ] && download "$DL_URL"
    extract "$VKD3D" || { rm "$VKD3D" && echo "RMT-ERROR: Failed to extract vkd3d, skipping." && return 1; }
    cd "${VKD3D//.tar.zst/}" || exit
    ./setup_vkd3d_proton.sh install && "$WINESERVER" -w
    cd "$OLDPWD" || exit
    rm -rf "${VKD3D//.tar.zst/}"; }

vkd3d() { VKD3DVER="$(curl -s -m 5 https://api.github.com/jc141x/vkd3d-proton/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}' | cut -c 2-)"
    SYSVKD3D="$(command -v setup_vkd3d_proton)"
    vkd3d() { update
        [ -n "$SYSVKD3D" ] && echo -n "RMT: Using local vkd3d. | " && "$SYSVKD3D" install --symlink && "$WINESERVER" -w && applied
        [ -z "$SYSVKD3D" ] && echo -n "RMT: Using vkd3d from github. | " && github_vkd3d && echo "$VKD3DVER" >"$WINEPREFIX/.vkd3d"; }
[[ ! -f "$WINEPREFIX/.vkd3d" && -z "$(status)" ]] && vkd3d
[[ -f "$WINEPREFIX/.vkd3d" && -n "$VKD3DVER" && "$VKD3DVER" != "$(awk '{print $1}' "$WINEPREFIX/.vkd3d")" ]] && { rm -f vkd3d-proton-*.tar.zst || true; } && echo "updating vkd3d" && vkd3d
echo -n "RMT: vkd3d up-to-date. | "; }

win10() { status || return; update; "$WINE" winecfg -v win10; applied; }; win81() { status || return; update; "$WINE" winecfg -v win81; applied; }
win8() { status || return; update; "$WINE" winecfg -v win8; applied; }; win2008r2() { status || return; update; "$WINE" winecfg -v win2008r2; applied; }; win2008() { status || return; update; "$WINE" winecfg -v  win2008; applied; }; win7() { status || return; update; "$WINE" winecfg -v win7; applied; }; winvista() { status || return; update; "$WINE" winecfg -v winvista; applied; }; win2003() { status || return; update; "$WINE" winecfg -v win2003; applied; }; win2k() { status || return; update; "$WINE" winecfg -v win2k; applied; }; winme() { status || return; update; "$WINE" winecfg -v winme; applied; }
win98() { status || return; update; "$WINE" winecfg -v win98 applied; }; win95() { status || return; update; "$WINE" winecfg -v win95; applied; }; win98() { status || return; update; "$WINE" winecfg -v win98; applied; }; winnt40() { status || return; update; "$WINE" winecfg -v winnt40; applied; }; winnt351() { status || return; update; "$WINE" winecfg -v winnt351; applied; }; win31() { status || return; update; "$WINE" winecfg -v win31 applied; }; win30() { status || return; update; "$WINE" winecfg -v win30; applied; }; win20() { status || return; update; "$WINE" winecfg -v win20; applied; }
winxp() { status || return; update; [ "$WINEARCH" = "win64" ] && "$WINE" winecfg -v winxp64; [ "$WINEARCH" = "win32" ] && "$WINE" winecfg -v winxp; applied; }

directx() { status || return; update
cp -r "$RMTCONTENT"/directx/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"; regedit "$RMTCONTENT"/directx/directx.reg
_dlls=( xactengine2_0.dll xactengine2_1.dll xactengine2_2.dll xactengine2_3.dll xactengine2_4.dll xactengine2_5.dll xactengine2_6.dll xactengine2_7.dll xactengine2_8.dll xactengine2_9.dll xactengine2_10.dll # xactengine 2.x
        xactengine3_0.dll xactengine3_1.dll xactengine3_2.dll xactengine3_3.dll xactengine3_4.dll xactengine3_5.dll xactengine3_6.dll xactengine3_7.dll # xactengine 3.x
        xaudio2_0.dll xaudio2_1.dll xaudio2_2.dll xaudio2_3.dll xaudio2_4.dll xaudio2_5.dll xaudio2_6.dll xaudio2_7.dll # xaudio
      )
regsvr32 ${_dlls[@]}; applied; }

mf() { status || return; update; regedit "$RMTCONTENT"/mf/mf.reg; regsvr32 colorcnv.dll msmpeg2adec.dll msmpeg2vdec.dll; applied; }
wmp11() { status || return; mf; update; cp -r "$RMTCONTENT"/wmp11/files/drive_c/* "$WINEPREFIX/drive_c/"; regedit "$RMTCONTENT"/wmp11/wmp11.reg; regsvr32 dispex.dll jscript.dll scrobj.dll scrrun.dll vbscript.dll wshcon.dll wshext.dll; applied; }
directshow() { status || return; update; cp -r "$RMTCONTENT"/directshow/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"; regedit "$RMTCONTENT"/directshow/directshow.reg; regsvr32 amstream.dll qasf.dll qcap.dll qdvd.dll qedit.dll quartz.dll; applied; }
directplay() { status || return; update; cp -r "$RMTCONTENT"/directplay/files/drive_c/windows/syswow64/* "$WINEPREFIX/drive_c/windows/syswow64"
regedit "$RMTCONTENT"/directplay/directplay.reg; regsvr32 dplayx.dll dpnet.dll dpnhpast.dll dpnhupnp.dll; applied; }
dotnet35() { status || return; remove-mono; update; cp -r "$RMTCONTENT"/dotnet35/files/drive_c/* "$WINEPREFIX/drive_c/"; regedit "$RMTCONTENT"/dotnet35/dotnet35.reg; applied; }
quicktime() { status || return; update; cp -r "$RMTCONTENT"/quicktime/files/drive_c/* "$WINEPREFIX/drive_c/"; regedit "$RMTCONTENT"quicktime/quicktime.reg; applied; }
physx() { status || return; update; cp -r "$RMTCONTENT"/physx/files/drive_c/* "$WINEPREFIX/drive_c/"; regedit "$RMTCONTENT"/physx/physx.reg; applied; }
vcrun() { status || return; update; cp -r "$RMTCONTENT"/vcrun/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"; regedit "$RMTCONTENT"/vcrun/vcrun.reg; applied; };
cinepak() { status || return; update; cp -r "$RMTCONTENT"/cinepak/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"; regedit "$RMTCONTENT"/cinepak/cinepak.reg; applied; };
corefonts() { status || return; update; cp -r "$RMTCONTENT"/vcrun/files/drive_c/windows/* "$WINEPREFIX/drive_c/windows/"; regedit "$RMTCONTENT"/vcrun/vcrun.reg; applied; }

for i in "$@"; do
    # Check if function exists
    if type "$i" &>/dev/null; then
        "$i"
    else exit
    fi
done
