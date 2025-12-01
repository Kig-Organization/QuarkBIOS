;
; QuarkBIOS
; Copyright (C) 2025 KiG Organizatio
;
; This file is part of QuarkBIOS.

; QuarkBIOS is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

; QuarkBIOS is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
along with QuarkBIOS.  If not, see <http://www.gnu.org/licenses/>.


org 0x7C00  ; BIOS entry point

; Subroutine to initialize hardware
init_hardware:
    ; Initialize PIC (Programmable Interrupt Controller)
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    ret

; Subroutine to check for Esc key press
check_esc_key:
    mov ah, 0x01    ; Check for key press
    int 0x16
    jz no_key       ; If no key pressed, continue
    mov ah, 0x00    ; Get key
    int 0x16
    cmp al, 0x1B    ; Compare with Esc key (0x1B)
    je enter_bios   ; If Esc, enter BIOS
no_key:
    ret

enter_bios:
    call init_vga_graphics
    call draw_gui
    ret

; Subroutine to initialize VGA graphics mode
init_vga_graphics:
    mov ax, 0x13    ; Set 320x200 graphics mode (256 colors)
    int 0x10
    ret

; Subroutine to draw the GUI
; Draws a green background and white text
; Displays hardware information

; VGA memory starts at 0xA000:0000
; Each pixel is one byte (color index)
draw_gui:
    ; Fill screen with green background (color index 2)
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov al, 2       ; Green color index
    mov cx, 64000   ; 320x200 pixels
    rep stosb       ; Fill VGA memory

    ; Draw white text
    mov si, hardware_info
    mov di, 0       ; Start at top-left corner
    call draw_text
    ret

; Subroutine to draw text on the screen
draw_text:
    ; Input: SI = string address, DI = VGA memory offset
.next_char:
    lodsb           ; Load next character from SI into AL
    cmp al, 0
    je .done        ; If null terminator, end
    ; Draw character (8x8 font)
    call draw_char
    add di, 8       ; Move to next character position
    jmp .next_char
.done:
    ret

; Subroutine to draw a single character (8x8 font)
draw_char:
    ; Input: AL = character, DI = VGA memory offset
    push ax
    push bx
    push cx
    push dx
    ; Example: Draw a simple block for each character
    mov cx, 8       ; 8 rows per character
.draw_row:
    mov bx, di      ; Save current position
    mov dx, 8       ; 8 pixels per row
.draw_pixel:
    mov byte [es:bx], 15 ; White color index
    inc bx
    dec dx
    jnz .draw_pixel
    add di, 320     ; Move to next row
    loop .draw_row
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Subroutine to load the operating system
load_os:
    mov ax, 0x0000  ; Segment for loading
    mov es, ax
    mov bx, 0x7E00  ; Offset for loading
    mov ah, 0x02    ; Read sectors function
    mov al, 1       ; Number of sectors to read
    mov ch, 0       ; Cylinder 0
    mov cl, 2       ; Sector 2
    mov dh, 0       ; Head 0
    mov dl, 0x80    ; Drive 0 (first hard disk)
    int 0x13        ; BIOS disk interrupt
    jc load_error   ; Jump if carry flag is set (error)
    jmp 0x0000:0x7E00 ; Jump to loaded code

load_error:
    mov si, error_msg
    call draw_text
    ret

start:
    cli             ; Disable interrupts
    xor ax, ax      ; Zero out AX register
    mov ds, ax      ; Set data segment to 0
    mov es, ax      ; Set extra segment to 0

    ; Initialize hardware
    call init_hardware

    ; Check for Esc key press to enter BIOS
    call check_esc_key

    ; Load the operating system if Esc not pressed
    call load_os

    ; Hang the system
hang:
    hlt
    jmp hang

hardware_info db 'QuarkBIOS Hardware Info:', 0x0D, 0x0A
              db 'CPU: Intel 8086', 0x0D, 0x0A
              db 'RAM: 640 KB', 0x0D, 0x0A
              db 'Disk: 1.44 MB Floppy', 0x0D, 0x0A
              db 0

error_msg db 'Disk Load Error!', 0

times 510-($-$$) db 0  ; Fill the rest of the boot sector with zeros

    dw 0xAA55          ; Boot sector signature

