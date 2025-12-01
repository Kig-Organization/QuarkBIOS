REM QuarkBIOS
REM Copyright (C) 2025 KiG Organizatio
REM
REM This file is part of QuarkBIOS.
REM
REM QuarkBIOS is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM
REM QuarkBIOS is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with QuarkBIOS.  If not, see <http://www.gnu.org/licenses/>.



@echo off
REM Run script for QuarkBIOS

REM Check if QEMU is installed
where qemu-system-x86 >nul 2>nul
if %errorlevel% neq 0 (
    echo QEMU not found! Please install QEMU and add it to your PATH.
    exit /b %errorlevel%
)

REM Run the BIOS in QEMU

qemu-system-x86 -drive format=raw,file=..\build\boot.bin -boot a


