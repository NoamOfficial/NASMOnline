section .bss
align 2
PIOData: resw 4096       ; 16 sectors * 512 bytes / 2 = 4096 words
count:   resw 1          ; number of sectors to transfer (16-bit safe)

section .text
global PIO_Transfer

SECTOR_COUNT_LOW   EQU 0x1F2
LBA_LOW_LOW        EQU 0x1F3
LBA_MID_LOW        EQU 0x1F4
LBA_HIGH_LOW       EQU 0x1F5
LBA_HIGH_BITS      EQU 0x1F6
COMMAND_REG        EQU 0x1F7
STATUS_REG         EQU 0x1F7
DATA_REG           EQU 0x1F0

;--------------------------------------
; 420 ns delay: 4 dummy status reads
;--------------------------------------
delay_420ns:
    in al, STATUS_REG
    in al, STATUS_REG
    in al, STATUS_REG
    in al, STATUS_REG
    ret

;--------------------------------------
; Wait until BSY=0 and DRQ=1
;--------------------------------------
wait_drq:
    call delay_420ns
.wait:
    in al, STATUS_REG
    test al, 0x88      ; BSY=0, DRQ=1
    cmp al, 0x08
    jne .wait
    ret

;--------------------------------------
; PIO Transfer Dispatcher
; AH=0x00 -> Write, AH=0x01 -> Read
;--------------------------------------
PIO_Transfer:
    cmp ah, 0x00
    je PIO_Write
    cmp ah, 0x01
    je PIO_Read
    ret

;--------------------------------------
; WRITE MULTIPLE EXT (48-bit LBA) with REP OUTSW
;--------------------------------------
PIO_Write:
    push dx
    push cx
    push si

    mov si, PIOData
    mov cx, [count]          ; number of sectors
    xor bx, bx               ; LBA high byte counter

write_loop:
    call wait_drq

    ; ---- Send high bytes first (48-bit LBA) ----
    mov dx, SECTOR_COUNT_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_LOW_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_MID_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_HIGH_LOW
    mov al, 0
    out dx, al

    call delay_420ns

    ; ---- Send low bytes (actual LBA) ----
    mov dx, SECTOR_COUNT_LOW
    mov al, 1            ; 1 sector per command
    out dx, al
    mov dx, LBA_LOW_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_MID_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_HIGH_LOW
    mov al, bl
    out dx, al
    mov dx, LBA_HIGH_BITS
    mov al, 0xE0         ; master + top LBA bits
    out dx, al

    call delay_420ns

    ; ---- Issue WRITE MULTIPLE EXT ----
    mov dx, COMMAND_REG
    mov al, 0xCD
    out dx, al

    call wait_drq

    ; ---- REP OUTSW stream buffer 512 bytes (256 words) ----
    mov dx, DATA_REG
    mov si, PIOData
    mov cx, 256            ; 256 words per sector
    rep outsw

    add si, 256*2          ; advance buffer pointer
    inc bl                  ; increment high LBA byte
    dec cx
    jnz write_loop

    pop si
    pop cx
    pop dx
    ret

;--------------------------------------
; READ MULTIPLE EXT (48-bit LBA) with REP INSW
;--------------------------------------
PIO_Read:
    push dx
    push cx
    push di

    mov di, PIOData
    mov cx, [count]
    xor bx, bx               ; LBA high byte counter

read_loop:
    call wait_drq

    ; ---- Send high bytes first (48-bit LBA) ----
    mov dx, SECTOR_COUNT_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_LOW_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_MID_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_HIGH_LOW
    mov al, 0
    out dx, al

    call delay_420ns

    ; ---- Send low bytes (actual LBA) ----
    mov dx, SECTOR_COUNT_LOW
    mov al, 1
    out dx, al
    mov dx, LBA_LOW_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_MID_LOW
    mov al, 0
    out dx, al
    mov dx, LBA_HIGH_LOW
    mov al, bl
    out dx, al
    mov dx, LBA_HIGH_BITS
    mov al, 0xE0
    out dx, al

    call delay_420ns

    ; ---- Issue READ MULTIPLE EXT ----
    mov dx, COMMAND_REG
    mov al, 0x25
    out dx, al

    call wait_drq

    ; ---- REP INSW stream 512 bytes (256 words) ----
    mov dx, DATA_REG
    mov di, PIOData
    mov cx, 256
    rep insw

    add di, 256*2
    inc bl
    dec cx
    jnz read_loop

    pop di
    pop cx
    pop dx
    ret










