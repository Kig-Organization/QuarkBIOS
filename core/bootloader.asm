; bootloader.asm — MBR (512 байт), загрузка UI из следующих секторов
BITS 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld

    ; текстовый режим 80x25
    mov ax, 0x0003
    int 0x10

    ; загрузить 2 сектора начиная с LBA=1 в 0000:8000
    mov bx, 0x8000       ; смещение
    mov ah, 0x02         ; функция BIOS: чтение
    mov al, 2            ; количество секторов
    mov ch, 0            ; цилиндр
    mov cl, 2            ; сектор (1=MBR, 2=следующий)
    mov dh, 0            ; головка
    mov dl, 0x80         ; диск (0x80 = первый HDD; для флоппи ставь 0)
    int 0x13
    jc disk_error

    ; передать управление загруженному коду
    jmp 0x0000:0x8000

disk_error:
    ; простая надпись об ошибке
    mov si, ErrStr
    call PrintStrBIOS
hang:
    jmp hang

; BIOS teletype print
PrintStrBIOS:
.next:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp .next
.done:
    ret

ErrStr: db "Disk read error",0

times 510-($-$$) db 0
dw 0xAA55
