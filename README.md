# Kryptonite
Kryptonite enables external GPUs on Macs using Thunderbolt 1 and 2 without compromising on Mac security features such as **System Integrity Protection**, **FileVault**, and **Authenticated-Root**.

Unlike [PurgeWrangler](https://github.com/mayankk2308/purge-wrangler), which requires these security features disabled and modifies kernel extensions on the root volume, **Kryptonite** injects patches via EFI and performs them in memory, when the offending kernel extensions load. This project supercedes the PurgeWrangler system.

## Installation
To be completed. A front-end installer will provide the necessary directions and guidance.

## System
**Kryptonite** leverages [OpenCore](https://github.com/acidanthera/OpenCorePkg) with a heavily tweaked and simplified configuration for native Macs to inject kernel/kext patches into macOS during boots. The patches themselves are implemented in a **kernel extension** named **Kryptonite** that leverages [Lilu](https://github.com/acidanthera/Lilu) which can patch kexts and processes in memory.

You can control **Kryptonite**'s behavior using boot-args specified in the OpenCore **config.plist**. The kernel extension supports the following boot arguments:

| Boot Arg | Description |
| :----------------: | :------------ |
| `-krydisable` | Disables **Kryptonite** on boot. |
| `-krydbg` | Enables debugging for **Kryptonite**. |
| `-krybeta` | Enables **Kryptonite** on beta/untested versions of macOS. |
| `krygpu=` | Provide GPU vendor to patch for. Must be `AMD` or `NVDA`. |
| `krytbtv=` | Provide Thunderbolt NHI version. Required for **macOS ≤ 10.15**. Must be `1` or `2`. |

## License
This project is licensed under [GPL-3.0](./LICENSE.md), while its underlying dependencies such as [OpenCore](https://github.com/acidanthera/OpenCorePkg) and [Lilu](https://github.com/acidanthera/Lilu) are licensed under BSD-3-Clause license.

## Credits
- [Apple](https://www.apple.com) for macOS.
- [acidanthera](https://github.com/acidanthera/) and it's contributors for [OpenCore](https://github.com/acidanthera/OpenCorePkg).
- [acidanthera](https://github.com/acidanthera/) and it's contributors for [Lilu](https://github.com/acidanthera/Lilu).
