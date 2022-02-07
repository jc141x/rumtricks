<div align="center">
  <h1>Rumtricks</h1>
</div>

<p align="center">
  Installer-less proper alternative to winetricks focused on speed and reliability.
</p>

![reposize](https://img.shields.io/github/repo-size/goldenboy313/rumtricks)![lines](https://img.shields.io/tokei/lines/github/goldenboy313/rumtricks)![licence](https://img.shields.io/github/license/goldenboy313/rumtricks)![lastcommit](https://img.shields.io/github/last-commit/goldenboy313/rumtricks)[![Matrix](https://matrix.to/img/matrix-badge.svg)](https://matrix.to/#/!SlYhhmreXjJylcsjfn:tedomum.net?via=matrix.org&via=tedomum.net)

## Features

* Stability: not relying on exes to install means better reliability
* Small size: uses ZSTD to compress and decompress files
* Download speed: downloads fast from a github repository
* Hash check: checking hashes to be sure our installation works
* Install speed: everything installs faster due to minimal and better code
* Dependencies: depends only on wine and zstd

## Installation

Rumtricks AUR and MPR package is planned to be released in the near future.

Make sure you have `Wine` and `Zstd` installed before you continue.

You can download rumtricks with this simple one liner:

```bash
wget https://raw.githubusercontent.com/goldenboy313/rumtricks/main/rumtricks.sh
```

The script will be placed in the root of the directory you ran the command from.

## Basic usage

Rumtricks needs a `WINEPREFIX` to install verbs into

`export WINEPREFIX="/path/to/prefix" ./rumtricks.sh (verb)`

If `WINEPREFIX` isn't provided rumtricks will install everything into the default wine prefix in `~/.wine`


## List of available verbs

name | Description
--- | ---
cinepak | Cinepak Codec
corefonts | Microsoft Core fonts
directshow | Microsoft DirectShow runtime (amstream and quartz)
directplay | Microsoft Directplay
directx | Microsoft DirectX End-User Runtime (June 2010)
dxvk | Vulkan-based translation layer for Direct3D 9/10/11
dxvk-async | dxvk with async patches
dxvk-custom | install any dxvk version (usage: ./rumtricks.sh dxvk-custom <<< "0.54")
isolate | Isolate the prefix by removing symbolinks to $HOME
mf | Microsoft Media Foundation
mono | Open-source and cross-platform implementation of the .NET Framework
remove-mono | Remove mono installation from the prefix
physx | Nvidia PhysX
quicktime | Apple QuickTime
update-self | Update rumtricks.sh to the latest version
vcrun2003 | Microsoft Visual C++ 2003 Redistributable
vcrun2005 | Microsoft Visual C++ 2005 Redistributable
vcrun2008 | Microsoft Visual C++ 2008 Redistributable
vcrun2010 | Microsoft Visual C++ 2010 Redistributable
vcrun2012 | Microsoft Visual C++ 2012 Redistributable
vcrun2013 | Microsoft Visual C++ 2013 Redistributable
vcrun2015 | Microsoft Visual C++ 2015 Redistributable
vcrun2017 | Microsoft Visual C++ 2017 Redistributable
vcrun2019 | Microsoft Visual C++ 2019 Redistributable
vdesktop | Virtual desktop
vkdestop-d | Disable virtual desktop
vkd3d | Direct3D 12 API on top of Vulkan
vkd3d-jc141 | Use our master builds of vkd3d 'till we say to stop

## List of verbs for wineprefix windows version

name | Description
--- | ---
win10 | Set wineprefix version Windows to 10
win81 | Set wineprefix version Windows to 8.1
win8 | Set wineprefix version to Windows 8
win7 | Set wineprefix version to Windows 7
win2008r2 | Set wineprefix version to Windows 2008 R2
win2008 | Set wineprefix version to Windows 2008
winvista | Set wineprefix version to Windows Vista
win2003 | Set wineprefix version to Windows 2003
winxp | Set wineprefix version to Windows XP
winme | Set wineprefix version to Windows ME (32bit only)
win2k | Set wineprefix version to Windows 2000 (32bit only)
win98 | Set wineprefix version to Windows 98 (32bit only)
winnt40 | Set wineprefix version to Windows NT 4.0 (32bit only)
win95 | Set wineprefix version to Windows 95 (32bit only)
winnt351 | Set wineprefix version to Windows NT 3.51 (32bit only)
win31 | Set wineprefix version to Windows 3.1 (32bit only)
win30 | Set wineprefix version to Windows 3.0 (32bit only)
win20 | Set wineprefix version to Windows 2.0 (32bit only)

## Planned verbs in order

* [ ] faudio
* [ ] dotnet 1.1-4.8
* [ ] xna40

## Contributing [![contributions](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/goldenboy313/rumtricks/issues)[![Matrix](https://matrix.to/img/matrix-badge.svg)](https://matrix.to/#/!SlYhhmreXjJylcsjfn:tedomum.net?via=matrix.org&via=tedomum.net)

Thank you for considering contributing to Rumtricks!

If you would like to participate, you are welcome on our [matrix](https://matrix.to/#/!SlYhhmreXjJylcsjfn:tedomum.net?via=matrix.org&via=envs.net&via=tedomum.net) room.

We welcome any type of contribution, not only code. You can help with:
- **Suggestions**: Give suggestions on what to add next
- **QA**: File bug reports, the more details you can give the better (e.g. console logs)
- **Code**: Take a look at the [open issues](https://github.com/goldenboy313/rumtricks/issues).

<div align="center">
  <h1>johncena141 hacker group production</h1>
</div>
