; QuarkBIOS UI — real-mode x86 (NASM, 16-bit), стабильный VGA текстовый UI
; Видео: 80x25 текст, фон тёмно-синий, текст белый
; Вкладки: Main, Boot, Security, Exit
; Управление: ← →, Tab, Enter
; Модуль загружается по 0000:8000 (org 0x8000)

BITS 16
org 0x8000

%define VID_SEG     0xB800
%define COLS        80
%define ROWS        25

%define FG_WHITE    0x0F
%define BG_BLUE     0x10
%define ATTR_NORMAL (BG_BLUE | FG_WHITE)
%define ATTR_HEADER (0x1F)
%define ATTR_HILITE (0x1E)
%define ATTR_DIM    (0x17)
%define ATTR_FRAME  (0x1F)

%define TAB_MAIN     0
%define TAB_BOOT     1
%define TAB_SEC      2
%define TAB_EXIT     3
%define TAB_COUNT    4

start:
    ; фиксируем сегменты и направление — один раз
    push cs
    pop  ds
    mov  ax, VID_SEG
    mov  es, ax
    cld

    ; 80x25 текстовый режим
    mov ax, 0x0003
    int 0x10

    ; скрыть курсор
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

    ; UI
    call ClearScreen
    call DrawFrame
    mov byte [SelectedTab], TAB_MAIN
    call DrawHeaderAndTabs
    call DrawPage

MainLoop:
    xor ax, ax
    int 0x16            ; ожидание клавиши: AH=scan, AL=ASCII

    cmp ah, 0x4B        ; Left
    je  KeyLeft
    cmp ah, 0x4D        ; Right
    je  KeyRight
    cmp ah, 0x0F        ; Tab
    je  KeyTab
    cmp ah, 0x1C        ; Enter
    je  KeyEnter
    jmp MainLoop

KeyLeft:
    mov al, [SelectedTab]
    cmp al, 0
    je  .wrap
    dec al
    jmp .set
.wrap:
    mov al, TAB_COUNT-1
.set:
    mov [SelectedTab], al
    call DrawHeaderAndTabs
    call DrawPage
    jmp MainLoop

KeyRight:
    mov al, [SelectedTab]
    inc al
    cmp al, TAB_COUNT
    jb  .set
    xor al, al
.set:
    mov [SelectedTab], al
    call DrawHeaderAndTabs
    call DrawPage
    jmp MainLoop

KeyTab:
    mov al, [SelectedTab]
    inc al
    cmp al, TAB_COUNT
    jb  .set
    xor al, al
.set:
    mov [SelectedTab], al
    call DrawHeaderAndTabs
    call DrawPage
    jmp MainLoop

KeyEnter:
    call DrawPage
    jmp MainLoop

; -----------------------------
; Каркас: верх/низ и вертикальные границы
; -----------------------------
DrawFrame:
    ; верхняя линия (row 2)
    mov ax, 2
    mov dl, ATTR_FRAME
    call ClearRow

    ; нижняя линия (row 24)
    mov ax, 24
    mov dl, ATTR_FRAME
    call ClearRow

    ; вертикальные границы в строках 3..23
    mov cx, 21                      ; 21 строк
    mov bx, 3                       ; текущая строка
.vert_loop:
    ; левая граница (col=0)
    mov ax, COLS
    mul bx                          ; DX:AX = row*COLS
    shl ax, 1                       ; *2
    mov di, ax
    mov al, '|'                     ; символ
    mov ah, ATTR_FRAME
    stosw

    ; правая граница (col=79)
    mov ax, COLS
    mul bx
    shl ax, 1
    add ax, (COLS-1)*2
    mov di, ax
    mov al, '|'
    mov ah, ATTR_FRAME
    stosw

    inc bx
    loop .vert_loop
    ret

; -----------------------------
; Заголовок + вкладки
; -----------------------------
DrawHeaderAndTabs:
    ; заголовок (row 0)
    mov bx, 0
    mov si, HeaderTitle
    mov dl, ATTR_HEADER
    call PrintStringAt

    ; строка вкладок (row 1)
    mov ax, 1
    mov dl, ATTR_NORMAL
    call ClearRow

    mov al, [SelectedTab]
    mov [TmpTab], al

    ; Main
    mov bx, (1*COLS + 2)*2
    mov si, TabMain
    mov dl, ATTR_DIM
    call PrintStringAt
    mov al, [TmpTab]
    cmp al, TAB_MAIN
    jne .no_hl0
    mov bx, (1*COLS + 2)*2
    mov si, TabMain
    mov dl, ATTR_HILITE
    call PrintStringAt
.no_hl0:

    ; Boot
    mov bx, (1*COLS + 10)*2
    mov si, TabBoot
    mov dl, ATTR_DIM
    call PrintStringAt
    mov al, [TmpTab]
    cmp al, TAB_BOOT
    jne .no_hl1
    mov bx, (1*COLS + 10)*2
    mov si, TabBoot
    mov dl, ATTR_HILITE
    call PrintStringAt
.no_hl1:

    ; Security
    mov bx, (1*COLS + 19)*2
    mov si, TabSec
    mov dl, ATTR_DIM
    call PrintStringAt
    mov al, [TmpTab]
    cmp al, TAB_SEC
    jne .no_hl2
    mov bx, (1*COLS + 19)*2
    mov si, TabSec
    mov dl, ATTR_HILITE
    call PrintStringAt
.no_hl2:

    ; Exit
    mov bx, (1*COLS + 30)*2
    mov si, TabExit
    mov dl, ATTR_DIM
    call PrintStringAt
    mov al, [TmpTab]
    cmp al, TAB_EXIT
    jne .no_hl3
    mov bx, (1*COLS + 30)*2
    mov si, TabExit
    mov dl, ATTR_HILITE
    call PrintStringAt
.no_hl3:
    ret

; -----------------------------
; Страницы
; -----------------------------
DrawPage:
    ; очистить рабочую область 3..23
    mov ax, 3
    mov dl, ATTR_NORMAL
.clear_loop:
    push ax
    call ClearRow
    pop ax
    inc ax
    cmp ax, 24
    jb  .clear_loop

    ; заголовок страницы
    mov bx, (3*COLS + 2)*2
    mov si, PageTitle
    mov dl, ATTR_HEADER
    call PrintStringAt

    ; выбор страницы
    mov al, [SelectedTab]
    cmp al, TAB_MAIN
    je  DrawMain
    cmp al, TAB_BOOT
    je  DrawBoot
    cmp al, TAB_SEC
    je  DrawSecurity
    cmp al, TAB_EXIT
    je  DrawExit
    ret

DrawMain:
    ; BIOS Version
    mov bx, (5*COLS + 4)*2
    mov si, BiosVerLbl
    mov dl, ATTR_NORMAL
    call PrintStringAt
    mov bx, (5*COLS + 22)*2
    mov si, BiosVerVal
    mov dl, ATTR_NORMAL
    call PrintStringAt

    ; CPU Vendor
    mov bx, (7*COLS + 4)*2
    mov si, CpuInfoLbl
    mov dl, ATTR_NORMAL
    call PrintStringAt

    call GetCpuVendor
    mov bx, (7*COLS + 22)*2
    mov si, CpuVendorBuf
    mov dl, ATTR_NORMAL
    call PrintStringAt

    ; Mainboard
    mov bx, (9*COLS + 4)*2
    mov si, BoardInfoLbl
    mov dl, ATTR_NORMAL
    call PrintStringAt
    mov bx, (9*COLS + 22)*2
    mov si, BoardInfoVal
    mov dl, ATTR_NORMAL
    call PrintStringAt
    ret

DrawBoot:
    mov bx, (5*COLS + 4)*2
    mov si, BootInfoLbl
    mov dl, ATTR_NORMAL
    call PrintStringAt
    mov bx, (6*COLS + 4)*2
    mov si, BootInfoVal
    mov dl, ATTR_NORMAL
    call PrintStringAt
    ret

DrawSecurity:
    mov bx, (5*COLS + 4)*2
    mov si, SecInfoLbl
    mov dl, ATTR_NORMAL
    call PrintStringAt
    mov bx, (6*COLS + 4)*2
    mov si, SecInfoVal
    mov dl, ATTR_NORMAL
    call PrintStringAt
    ret

DrawExit:
    mov bx, (5*COLS + 4)*2
    mov si, ExitInfoLbl
    mov dl, ATTR_NORMAL
    call PrintStringAt
    mov bx, (7*COLS + 4)*2
    mov si, ExitInfoVal
    mov dl, ATTR_NORMAL
    call PrintStringAt
    ret

; -----------------------------
; Вывод (ES=VID_SEG, DS=CS, DF=0)
; -----------------------------
ClearScreen:
    xor di, di
    mov cx, COLS*ROWS
    mov ax, (ATTR_NORMAL << 8) | ' '
.rep:
    stosw
    loop .rep
    ret

; AX=row, DL=attr
ClearRow:
    mov bx, ax              ; BX=row
    mov ax, COLS
    mul bx                  ; DX:AX = row*COLS
    shl ax, 1               ; *2
    mov di, ax
    mov cx, COLS
    mov ah, dl
    mov al, ' '
.clr:
    stosw
    loop .clr
    ret

; BX = offset, SI = DS:string, DL = attr
PrintStringAt:
    mov di, bx
.next:
    lodsb
    test al, al
    jz   .done
    mov ah, dl
    stosw
    jmp  .next
.done:
    ret

; -----------------------------
; CPUID vendor — запись 12 байт по байтам
; -----------------------------
GetCpuVendor:
    pusha
    cld

    ; проверить поддержку CPUID через ID-флаг
    pushfd
    pop eax
    mov ebx, eax
    xor eax, 1<<21
    push eax
    popfd
    pushfd
    pop eax
    xor eax, ebx
    test eax, 1<<21
    jz .no_cpuid

    ; CPUID EAX=0: EBX, EDX, ECX = vendor
    xor eax, eax
    cpuid

    ; пишем EBX, EDX, ECX по байтам
    mov di, CpuVendorBuf

    ; EBX
    mov [di+0], bl
    mov [di+1], bh
    shr ebx, 16
    mov [di+2], bl
    mov [di+3], bh

    ; EDX
    mov [di+4], dl
    mov [di+5], dh
    shr edx, 16
    mov [di+6], dl
    mov [di+7], dh

    ; ECX
    mov [di+8], cl
    mov [di+9], ch
    shr ecx, 16
    mov [di+10], cl
    mov [di+11], ch

    mov byte [di+12], 0
    jmp .done

.no_cpuid:
    mov di, CpuVendorBuf
    mov si, NoCpuStr
    mov cx, 9
    rep movsb

.done:
    popa
    ret

; -----------------------------
; Данные (ASCII-only)
; -----------------------------
SelectedTab: db 0
TmpTab:      db 0

HeaderTitle: db " BIOS Setup Utility (C) KiG Computer Systems ",0
TabMain:     db "Main",0
TabBoot:     db "Boot",0
TabSec:      db "Security",0
TabExit:     db "Exit",0

PageTitle:   db " System Information ",0

BiosVerLbl:  db "BIOS Version:",0
BiosVerVal:  db "1.0 Test",0

CpuInfoLbl:  db "CPU Vendor:",0
CpuVendorBuf: times 13 db 0
NoCpuStr:    db "noCPUID ",0

BoardInfoLbl: db "Mainboard:",0
BoardInfoVal: db "Generic (DMI not parsed)",0

BootInfoLbl: db "Boot Options:",0
BootInfoVal: db "- (not implemented)",0

SecInfoLbl:  db "Security:",0
SecInfoVal:  db "- (not implemented)",0

ExitInfoLbl: db "Exit:",0
ExitInfoVal: db "Press Enter to continue...",0

Hang:
    jmp Hang
