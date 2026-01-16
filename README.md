![ASM](https://img.shields.io/badge/asm-6E4C13?style=for-the-badge&logo=asm&logoColor=white)
![C](https://img.shields.io/badge/c-00599C?style=for-the-badge&logo=c&logoColor=white)

# QuarkBIOS

QuarkBIOS is an open-source experimental Legacy BIOS and bootloader project for x86 / x86-64 platforms. The project implements 16-bit real-mode boot code and focuses on classic BIOS functionality: CPU initialization, basic hardware services, interrupt handling, and handoff to a higher-stage loader or kernel.

This repository is intended for education, research and practical experimentation with low-level system software. The project is not production-ready and is intended to be used in emulators or on designated test hardware only.

---

## Project structure

- `core/` — BIOS source code (assembly)
- `build/` — output directory for compiled binaries
- `docs/` — documentation, design notes, and references
- `tools/` — scripts and utilities for building, testing and running the BIOS

---

## Requirements

- NASM (Netwide Assembler) — to assemble the BIOS code
- MSYS2 - for build and emulation
- QEMU (Quick Emulator) — for testing in virtual environment
- Optional: GNU Make or scripts for build automation

---

## Build instructions

1. Install dependencies (example for Debian/Ubuntu):
```bash
sudo apt update
sudo apt install nasm qemu-system-x86
```
2. Build and run (in MSYS2):
```
nasm -f bin bootloader.asm -o boot.bin
nasm -f bin bios_ui.asm -o bios.bin
dd if=/dev/zero of=disk.img bs=512 count=2880
dd if=boot.bin of=disk.img conv=notrunc
dd if=bios.bin of=disk.img bs=512 seek=1 conv=notrunc
qemu-system-i386 -drive format=raw,file=disk.img
```

## Project goals and roadmap

QuarkBIOS aims to implement a minimal, well-documented Legacy BIOS with a clear development roadmap. Planned and prioritized items:

Minimal BIOS with Interrupt Vector Table and basic initialization

POST emulation and basic hardware checks

INT 10h (video services) minimal support

INT 13h (disk services) basic access and boot sector loading

Protected mode transition and higher-stage loader support

There is also a minimalistic text interface.

Serial debug output for development and testing

Comprehensive documentation for subsystems and interfaces

Planned items are tracked in the repository and will be updated as development progresses.

## Interface Preview

![QuarkBIOS UI](C:\Users\PC\Pictures\Screenshots\biosui.png)

## Contribution

Contributions are welcome. Please follow the repository guidelines before submitting changes:

Fork the repository

Create a feature branch

Make changes and add tests where applicable

Open a Pull Request

Detailed contribution rules and workflow are provided in CONTRIBUTING.md. Contributors must agree that their contributions are licensed under the repository license.

## License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Authors and maintainers

Konstantin Kornienko — Lead developer, architect

Dmitry Maximenko — Developer

Project maintained by KiG Organization, 2025.

## Disclaimer

QuarkBIOS is experimental research software. It is not intended for production use. Use on real hardware may be unsafe. Test in virtualized environments or on disposable hardware.

## Contact and acknowledgements

For project communication and coordination, use the repository issues and pull requests. Additional contact: Telegram https://t.me/kig_org
