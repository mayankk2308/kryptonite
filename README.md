# Kryptonite
![Script Version](https://img.shields.io/github/release/mayankk2308/kryptonite.svg?style=for-the-badge)
![macOS Support](https://img.shields.io/badge/macOS-10.13.4+-orange.svg?style=for-the-badge) ![Github All Releases](https://img.shields.io/github/downloads/mayankk2308/kryptonite/total.svg?style=for-the-badge) [![paypal](https://www.paypalobjects.com/digitalassets/c/website/marketing/apac/C2/logos-buttons/optimize/34_Yellow_PayPal_Pill_Button.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mayankk2308@icloud.com&lc=US&item_name=Development%20of%20Kryptonite&no_note=0&currency_code=USD&bn=PP-DonationsBF:btn_donate_SM.gif:NonHostedGuest)

Kryptonite enables external GPUs on Macs using Thunderbolt 1 and 2 without compromising on Mac security features such as **System Integrity Protection**, **FileVault**, and **Authenticated-Root**.

Unlike [PurgeWrangler](https://github.com/mayankk2308/purge-wrangler), which requires these security features disabled and modifies kernel extensions on the root volume, **Kryptonite** injects patches via EFI and performs them in memory, when the offending kernel extensions load. This project supercedes the PurgeWrangler system.

## System
**Kryptonite** leverages [OpenCore](https://github.com/acidanthera/OpenCorePkg) with a heavily simplified configuration for native Macs to inject kernel/kext patches into macOS during boots. The patches themselves are implemented in a **kernel extension** named **Kryptonite** that leverages [Lilu](https://github.com/acidanthera/Lilu) which can patch kexts and processes in memory.

You can control **Kryptonite**'s behavior using boot-args specified in the OpenCore **config.plist**. The kernel extension supports the following boot arguments:

| Boot Arg | Description |
| :----------------: | :------------ |
| `-krydisable` | Disables **Kryptonite** on boot. |
| `-krydbg` | Enables debugging for **Kryptonite**. Must be used alongside `-liludbg`. |
| `-krybeta` | Enables **Kryptonite** on beta/untested versions of macOS. Must be used with `-lilubeta`. |
| `krygpu=` | Provide GPU vendor to patch for. Must be `AMD` or `NVDA`. |
| `krytbtv=` | Provide Thunderbolt NHI version. Required for **macOS ≤ 10.15**. Must be `1` or `2`. |

## Features
With **Kryptonite**, you get the following benefits over **PurgeWrangler**:
1. **One-time configuration**: You only have to set up **Kryptonite** once, and it will continue to work through Apple software updates.
2. **Security**: You can use your mac with all security features enabled - excluding **T2 chip** if used on those Macs.
3. **Clean system**: Because all patches are performed in memory, your system is untouched when booted without the **Kryptonite/OpenCore** disk.

## Installation
To start the process, copy-paste the following command into **Terminal**:
```shell
curl -qLs $(curl -qs "https://api.github.com/repos/mayankk2308/kryptonite/releases/latest" | grep '"browser_download_url":' | grep ".sh" | sed -E 's/.*"([^"]+)".*/\1/') > k.sh; sh k.sh; rm k.sh
```

If you are already using **OpenCore** like for running unsupported versions of macOS, let the installer know when asked. This will let the installer update your existing configuration with **Kryptonite** support. If this is your first time setting up **OpenCore**, the installer will require a disk to format. Currently APFS volumes are not supported, so if you want to use an internal volume, create an HFS/FAT32 volume in **Disk Utility**. The volume will then show up in the installer when selecting a volume to format. If you are trying to use this on **beta** versions of macOS, pleasee see the **Configuration** section below.

### Things Missing in the Installer
- Downloading NVIDIA Web Drivers for using a Maxwell or Pascal NVIDIA GPU on **macOS High Sierra**.
- Detecting and resizing APFS containers and create usable disks for **Kryptonite** during installation.
- Disabling discrete GPUs on Macs that need it to allow for displays connected to external GPUs to function.

### Configuration
To manually edit configurations, use [ProperTree](https://github.com/corpnewt/ProperTree#on-nix-systems) to open the **config.plist** file on your bootloader. This file is located on your bootloader disk in the `EFI/OC/` directory. If you are comfortable doing so, you can edit the file in **TextEdit** - just be careful with the format and XML tags. This section describes some common configuration changes you may want to make:

#### Beta Versions of macOS
By default, **Kryptonite** will be disabled on **beta** or **untested** versions of macOS. To enable this, you need to update the **boot-args** in your **config.plist**. Specifically, you need to **add** the following arguments:
```shell
-lilubeta -krybeta
```
Add these after the already-present **boot-args**.

#### Disabling NVIDIA Discrete GPU
If you are using an AMD eGPU with a Mac that has a discrete NVIDIA GPU, display outputs may not work on the eGPU. To fix this, you can disable the discrete GPU as follows:
1. Configure the bootloader to power off the NVIDIA GPU. Follow instructions [here](https://dortania.github.io/OpenCore-Install-Guide/extras/spoof.html). Use the **DeviceProperties** approach on that page.
2. **Add** the following to your **boot-args**:
  ```shell
  nv_disable=1
  ```
  This ensures that when booting without the bootloader, the GPU remains disabled so as not to flip the GPU mux back to discrete GPU on next boot.
3. Switch mux to iGPU:
  ```shell
  sudo nvram FA4CE28D-B62F-4C99-9CC3-6815686E30F9:gpu-power-prefs=%01%00%00%00
  ```
  Sometimes this may not work. A good indicator that it worked is that when you boot, the boot chime is heard but there is a small delay before the display backlight comes on. If it does not work, there is no other option but to retry.
  
Once configured, you will most likely not require any changes with respect to eGPU support. If there is a newer release of the **Kryptonite** packages and you want to get them, simply start the installation process (refer to section above) and when asked if you are already using OpenCore, answer no. Select your existing **Kryptonite** disk and format it. After that just follow the instructions in the script and you will have the latest packages.

## License
This project is licensed under [GPL-3.0](./LICENSE.md), while its underlying dependencies such as [OpenCore](https://github.com/acidanthera/OpenCorePkg) and [Lilu](https://github.com/acidanthera/Lilu) are licensed under BSD-3-Clause license.

## Credits

### Software and Frameworks
- [Apple](https://www.apple.com) for macOS.
- [acidanthera](https://github.com/acidanthera/) and it's contributors for [OpenCore](https://github.com/acidanthera/OpenCorePkg).
- [acidanthera](https://github.com/acidanthera/) and it's contributors for [Lilu](https://github.com/acidanthera/Lilu).

### Patches
- [@mayankk2308/@mac_editor](https://egpu.io/forums/profile/mac_editor/) for:
  - Thunderbolt patches for native eGFX support on **macOS 10.13.4-10.15.1**.
  - Updated Thunderbolt patches for native eGFX support on **macOS 10.15.1+**.
  - Bypass for Thunderbolt driver compatibility (**IOPCITunnelCompatible**) checks on **macOS 10.13.4+**.
- [@goalque](https://egpu.io/forums/profile/goalque/) for support for NVIDIA eGFX on **macOS 10.13.4+**.
- [@rgov](https://github.com/rgov) for Ti82 Thunderbolt patches - adapted for [Lilu](https://github.com/acidanthera/Lilu) by [@mac_editor](https://egpu.io/forums/profile/mac_editor/).
