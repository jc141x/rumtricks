## Basic usage

- Rumtricks needs a `WINEPREFIX` to install verbs into

`export WINEPREFIX="/path/to/prefix" bash rumtricks.sh (verb)`


### List of available verbs

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
dotnet35| Microsoft .NET 3.5
isolation | Isolating the prefix by removing symbolinks to $HOME
mf | Microsoft Media Foundation
mono | Open-source and cross-platform implementation of the .NET Framework
physx | Nvidia PhysX
quicktime | Apple QuickTime
update-self | Update rumtricks.sh to the latest version
vcrun | Microsoft Visual C++ Redistributable Bundle
vkd3d | Direct3D 12 API on top of Vulkan
wmp11 | Windows Media Player 11

### List of verbs for wineprefix windows version

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
