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

// mouse.c - Mouse handling for QuarkBIOS

#include "bios.h"

void init_mouse() {
    // Initialize mouse
    asm volatile (
        "mov $0x00, %%ax\n"
        "int $0x33\n"
        :
        :
        : "ax"
    );
}

void get_mouse_position(int* x, int* y) {
    // Get mouse position
    asm volatile (
        "mov $0x03, %%ax\n"
        "int $0x33\n"
        : "=c"(*x), "=d"(*y)
        :
        : "ax"
    );

}
