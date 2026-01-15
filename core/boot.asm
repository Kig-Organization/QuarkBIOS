; --- Security & Protection ---
security:
    ; TPM, PCR, SPI-flash protection, firmware signature check — заглушка
    ret
; --- Power Management ---
power_mgmt:
    ; P-States, C-States, энергосбережение — заглушка
    ret
; --- Compatibility Tables & Services ---
compat_tables:
    ; INT 10h (видео), INT 13h (диск) — реализованы через BIOS
    ; PCI IRQ Routing, MP/ACPI MADT — заглушки
    ret
; --- Flash Update Mechanism ---
flash_update:
    mov si, flash_msg
    call draw_text
    ret

flash_msg db 'Flash Update: Not Supported', 0
; --- POST (Power-On Self Test) ---
post:
    ; Тест CPU: просто выполняем NOP
    nop

    ; Тест ОЗУ: повторяем mem_init
    call mem_init

    ; Тест видеовывода: выводим POST сообщение
    mov si, post_msg
    call draw_text

    ; Тест клавиатуры: проверяем наличие (BIOS int 16h)
    mov ah, 0x01
    int 0x16
    jz post_kbd_fail
    ret

post_kbd_fail:
    mov si, kbd_error_msg
    call draw_text
    jmp hang

post_msg db 'POST OK', 0
kbd_error_msg db 'Keyboard Error!', 0
; --- SMBIOS/DMI Table Generation ---
smbios_tables:
    ; Заглушка: размещаем DMI Entry Point Structure в 0x000F0000
    mov ax, 0xF000
    mov es, ax
    mov di, 0x0000
    mov si, dmi_data
    mov cx, dmi_data_end - dmi_data
    rep movsb
    ret

dmi_data db '_SM_', 0         ; Anchor String
         db 0                 ; Checksum
         db 0x1F              ; Length
         db 0x02              ; Major Version
         db 0x08              ; Minor Version
         db 0                 ; Max Structure Size
         db 0                 ; Entry Point Revision
         db 0,0,0,0,0         ; Formatted Area
         db '_DMI_', 0        ; Intermediate Anchor
         db 0                 ; Intermediate Checksum
         db 0,0,0,0           ; Table Length, Table Address
         db 0                 ; Number of Structures
         db 0                 ; BCD Revision
dmi_data_end:
; --- ACPI Table Generation ---
acpi_tables:
    ; Заглушка: размещаем ACPI Root System Description Pointer (RSDP) в 0x000E0000
    mov ax, 0xE000
    mov es, ax
    mov di, 0x0000
    mov si, rsdp_data
    mov cx, rsdp_data_end - rsdp_data
    rep movsb
    ret

rsdp_data db 'RSD PTR ', 0    ; Signature
          db 1                ; Checksum
          db 'OEMID '         ; OEMID (6 bytes)
          db 0                ; Revision
          dd 0                ; RSDT address (заглушка)
rsdp_data_end:
; --- Peripheral Initialization ---
periph_init:
    ; USB (заглушка)
    ; Для legacy — пропускаем, для новых — требуется отдельный драйвер

    ; SATA/NVMe (заглушка)
    ; Для legacy — пропускаем, для новых — требуется отдельный драйвер

    ; UART (COM1)
    mov dx, 0x3F8
    mov al, 0x00
    out dx, al

    ; SPI/I2C (заглушка)
    ; Для legacy — пропускаем

    ; iGPU (заглушка)
    ; Для legacy — VGA уже инициализирован

    ret
; --- Memory Initialization ---
mem_init:
    ; Используем INT 12h для определения объёма conventional memory (до 640 КБ)
    int 0x12
    mov [mem_kb], ax

    ; Минимальный тест: запись/чтение в начало и конец conventional memory
    mov ax, 0x0000
    mov es, ax
    mov di, 0x0000
    mov al, 0xAA
    stosb
    mov al, [es:0x0000]
    cmp al, 0xAA
    jne mem_fail

    mov ax, 0x9FFF
    mov es, ax
    mov di, 0xFFFF
    mov al, 0x55
    stosb
    mov al, [es:0xFFFF]
    cmp al, 0x55
    jne mem_fail

    ret

mem_fail:
    ; Ошибка памяти — зависаем
    jmp hang

mem_kb dw 0
; boot.asm - BIOS with pixel-based GUI

org 0x7C00  ; BIOS entry point

; Subroutine to initialize hardware

init_hardware:
    ; --- Настройка PIC (Programmable Interrupt Controller) ---
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

    ; --- Настройка PCI (только базовая инициализация для старых систем) ---
    ; Для legacy: просто сканируем шину 0, устройство 0, функция 0
    mov dx, 0xCF8
    mov eax, 0x80000000 ; PCI config address (bus 0, dev 0, func 0, reg 0)
    out dx, eax
    mov dx, 0xCFC
    in  eax, dx         ; Считываем Vendor/Device ID

    ; --- Включение APIC/IOAPIC (если поддерживается) ---
    ; Для старых систем пропускаем, для новых — требуется отдельная реализация

    ; --- Базовые регистры контроллеров (пример: таймер PIT) ---
    mov al, 0x36
    out 0x43, al        ; Установить режим PIT
    mov ax, 0xFFFF
    out 0x40, al        ; Максимальное значение счётчика

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
    call bios_setup
    ret

; --- BIOS Setup Utility ---
bios_setup:
    mov si, setup_menu
    call draw_text
    ; Навигация по меню (заглушка)
    ; Здесь можно реализовать обработку стрелок и Enter
    ret

setup_menu db 'BIOS Setup:', 0x0D, 0x0A
           db '1. Boot Order', 0x0D, 0x0A
           db '2. CPU Params', 0x0D, 0x0A
           db '3. Devices', 0x0D, 0x0A
           db '4. Date/Time', 0x0D, 0x0A
           db '5. Security', 0x0D, 0x0A
           db 'ESC - Exit', 0x0D, 0x0A
           db 0

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


; --- Bootstrapping (OS Loader) ---
load_os:
    ; Заглушка: выбор загрузочного устройства (по умолчанию HDD, 0x80)
    mov dl, 0x80        ; 0x80 = HDD, 0x00 = FDD
    mov ax, 0x0000      ; Сегмент для загрузки
    mov es, ax
    mov bx, 0x7E00      ; Смещение для загрузки
    mov ah, 0x02        ; BIOS: Read Sectors
    mov al, 1           ; 1 сектор
    mov ch, 0           ; Cylinder 0
    mov cl, 1           ; Sector 1 (MBR)
    mov dh, 0           ; Head 0
    int 0x13            ; BIOS disk interrupt
    jc load_error       ; Ошибка чтения
    jmp 0x0000:0x7E00   ; Передать управление загруженному коду

load_error:
    mov si, error_msg
    call draw_text
    ret


start:
    cli                 ; Отключить прерывания
    xor ax, ax          ; Сбросить AX
    mov ds, ax          ; Сегмент данных = 0
    mov es, ax          ; Сегмент extra = 0
    mov ss, ax          ; Сегмент стека = 0
    mov sp, 0x7C00      ; Установить стек


    call cpu_init       ; Инициализация процессора
    call init_hardware  ; Инициализация чипсета/платформы
    call mem_init       ; Инициализация памяти
    call periph_init    ; Инициализация периферии
    call acpi_tables    ; Генерация ACPI-таблиц
    call smbios_tables  ; Генерация SMBIOS/DMI
    call post           ; POST
    call check_esc_key  ; Проверка нажатия Esc
    call load_os        ; Загрузка ОС, если не вход в BIOS

    ; Зависнуть
hang:
    hlt
    jmp hang

; --- CPU Initialization ---
cpu_init:
    ; Сбросить флаги, подготовить CPU к работе
    cld                 ; Очищаем флаг направления
    ; Отключить кеш (для старых CPU)
    mov eax, cr0
    or  al, 0x10        ; Установить бит CD (Cache Disable)
    mov cr0, eax
    ; MTRR и микрокод — только для новых CPU, пропускаем для совместимости
    ret

hardware_info db 'QuarkBIOS Hardware Info:', 0x0D, 0x0A
              db 'CPU: Intel 8086', 0x0D, 0x0A
              db 'RAM: 640 KB', 0x0D, 0x0A
              db 'Disk: 1.44 MB Floppy', 0x0D, 0x0A
              db 0

error_msg db 'Disk Load Error!', 0

times 510-($-$$) db 0  ; Fill the rest of the boot sector with zeros
    dw 0xAA55          ; Boot sector signature