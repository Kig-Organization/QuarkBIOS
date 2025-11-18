⭐ QuarkBIOS

**QuarkBIOS is a 16-bit real-mode BIOS written entirely in x86 Assembly.** 🚀
It runs in real mode and is therefore compatible only with x86 platforms. QuarkBIOS is a young and ambitious project, designed for educational purposes to teach low-level programming techniques and demonstrate how a BIOS works internally. This project is perfect for anyone who wants to dive into computer architecture, assembly programming, and system internals. 💻✨

📁 Project Structure

_src/_ — Contains the source code for the BIOS

_build/_ — Output directory for compiled binaries

_docs/_ — Documentation, guides, and references

_tools/_ — Scripts and utilities for building, testing, and running the BIOS ⚙️

📦 Requirements

NASM (Netwide Assembler) — to assemble the code

QEMU (Quick Emulator) — for testing the BIOS in a virtual environment

Optional: GNU Make for automating the build process 🛠️

🔧 Build Instructions

Install dependencies

`sudo apt install nasm qemu-system-x86`


Build the BIOS

`./tools/build.sh`


Run in QEMU

`qemu-system-i386 -bios build/quarkbios.bin`


You should now see QuarkBIOS running in the emulator! 🎉

🎯 Project Goals / Roadmap

QuarkBIOS is growing, and here’s what we aim to implement:

 Minimal BIOS with interrupt vector table

 INT 10h (Video Services) support 🖥️

 INT 13h (Disk Services) support 💾

 Boot sector loading

 Power-On Self Test (POST) emulation ✅

 Full documentation for all subsystems 📚

 Support for user-defined extensions

This roadmap ensures that the project remains educational, extensible, and fun for contributors.

🤝 Contributing

We welcome contributions of all kinds! Whether it’s fixing bugs, adding new features, or improving documentation, your help is appreciated.

Fork the repository 🍴

Create a new branch 🌿

Make your changes ✍️

Open a pull request 🔄

Celebrate your contribution 😎✨

Every PR helps QuarkBIOS grow and improves the learning experience for everyone.

📜 License

QuarkBIOS is released under the GNU AGPLv3 License. 🛡️
This ensures that the project remains free and open-source, while also encouraging collaboration.

👥 Authors

_Konstantin Kornienko — Programmer, Architect, and Director_ 🧠

_Dmitry Maximenko — Programmer and Cool Guy_ 😎

**And many anonymous contributors…** 🤫

🧪 Created by _**KiG Organization**_

Thank you for exploring QuarkBIOS! We hope this project inspires you to learn, experiment, and create amazing low-level software. ❤️🚀

🔗 Links and acknowledgements
Telegram: https://t.me/kig_org

Special thanks to everyone who contributed to this project!
