section .data
PIOData:
    resb 8192           ; 16 sectors * 512 bytes
count db 0             ; number of sectors to transfer

SECTOR_COUNT_LOW   EQU 0x1F2
LBA_LOW_LOW        EQU 0x1F3
LBA_MID_LOW        EQU 0x1F4
LBA_HIGH_LOW       EQU 0x1F5
LBA_HIGH_BITS      EQU 0x1F6
COMMAND_REG        EQU 0x1F7
STATUS_REG         EQU 0x1F7
DATA_REG           EQU 0x1F0

section .text
global PIO_Transfer

;==============================
; Wait until BSY=0 and DRQ=1
;==============================
wait_drq:
    in al, STATUS_REG
    test al, 0x88      ; check BSY=0 and DRQ=1
    cmp al, 0x08
    jne wait_drq
    ret

;==============================
; PIO Transfer dispatcher
; AH=0x00 -> Write, AH=0x01 -> Read
;==============================
PIO_Transfer:
    cmp ah, 0x00
    je PIO_Write
    cmp ah, 0x01
    je PIO_Read
    ret

;==============================
; WRITE MULTIPLE (48-bit LBA)
;==============================
PIO_Write:
    push dx
    push cx
    push si
    push bx

    mov si, PIOData      ; buffer pointer
    mov bx, 0            ; upper LBA high byte
    mov bh, 0            ; optional upper mid byte

write_sector_loop:
    call wait_drq

    ;--- send high bytes first (48-bit LBA) ---
    mov dx, SECTOR_COUNT_LOW
    mov al, 1            ; sectors per command
    out dx, al
    mov dx, LBA_LOW_LOW
    out dx, al
    mov dx, LBA_MID_LOW
    out dx, 0             ; mid high 0
    mov dx, LBA_HIGH_LOW
    out dx, 0             ; high high 0

    ;--- send low bytes (actual LBA) ---
    mov dx, SECTOR_COUNT_LOW
    out dx, al            ; same sector count
    mov dx, LBA_LOW_LOW
    out dx, al            ; LBA low byte
    mov dx, LBA_MID_LOW
    out dx, bl            ; LBA mid byte
    mov dx, LBA_HIGH_LOW
    out dx, bh            ; LBA high byte
    mov dx, LBA_HIGH_BITS
    mov al, 0xE0          ; master + top LBA bits
    out dx, al

    ; Issue WRITE MULTIPLE EXT (48-bit)
    mov dx, COMMAND_REG
    mov al, 0xCD          ; WRITE MULTIPLE EXT
    out dx, al

    ; Stream buffer
    mov cx, 1024          ; 512 words
    mov dx, DATA_REG
    rep outsw

    ; increment buffer pointer
    add si, 512*4
    inc bh                 ; increment high LBA byte
    cmp bh, [count]
    jb write_sector_loop

    pop bx
    pop si
    pop cx
    pop dx
    ret

;==============================
; READ MULTIPLE (48-bit LBA)
;==============================
PIO_Read:
    push dx
    push cx
    push di
    push bx

    mov di, PIOData
    mov bx, 0
    mov bh, 0

read_sector_loop:
    call wait_drq

    ;--- send high bytes first ---
    mov dx, SECTOR_COUNT_LOW
    mov al, 1
    out dx, al
    mov dx, LBA_LOW_LOW
    out dx, al
    mov dx, LBA_MID_LOW
    out dx, 0
    mov dx, LBA_HIGH_LOW
    out dx, 0

    ;--- send low bytes (actual LBA) ---
    mov dx, SECTOR_COUNT_LOW
    out dx, al
    mov dx, LBA_LOW_LOW
    out dx, al
    mov dx, LBA_MID_LOW
    out dx, bl
    mov dx, LBA_HIGH_LOW
    out dx, bh
    mov dx, LBA_HIGH_BITS
    mov al, 0xE0
    out dx, al

    ; Issue READ MULTIPLE EXT (48-bit)
    mov dx, COMMAND_REG
    mov al, 0x25          ; READ MULTIPLE EXT
    out dx, al

    ; Stream disk to buffer
    mov cx, 1024
    mov dx, DATA_REG
    rep insw

    ; increment buffer pointer
    add di, 512*4
    inc bh
    cmp bh, [count]
    jb read_sector_loop

    pop bx
    pop di
    pop cx
    pop dx
    ret









