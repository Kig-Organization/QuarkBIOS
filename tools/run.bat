/*
 * This file is part of the QuarkBIOS project.
 *
 * Copyright (C) 2025 KiG Organization
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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
