;--------------------------------------
; UltimateOS PIO Driver Skeleton (x86)
;--------------------------------------
section .bss
align 2
PIOData: resw 4096       ; 16 sector buffer (512 bytes)
count:   resw 1        ; number of sectors to transfer (16-bit safe)

section .text
global PIO_Transfer

; ATA ports
SECTOR_COUNT_LOW   EQU 0x1F2
LBA_LOW_LOW        EQU 0x1F3
LBA_MID_LOW        EQU 0x1F4
LBA_HIGH_LOW       EQU 0x1F5
LBA_HIGH_BITS      EQU 0x1F6
COMMAND_REG        EQU 0x1F7
STATUS_REG         EQU 0x1F7
DATA_REG           EQU 0x1F0

;--------------------------------------
; 420 ns delay (4 dummy status reads)
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
.wait:
    in al, STATUS_REG
    test al, 0x88      ; BSY=0, DRQ=1
    cmp al, 0x08
    jne .wait
    call delay_420ns
    ret

;--------------------------------------
; PIO Transfer Dispatcher
; AH = 0x00 -> Write
; AH = 0x01 -> Read
;--------------------------------------
PIO_Transfer:
    cmp ah, 0x00
    je PIO_Write
    cmp ah, 0x01
    je PIO_Read
    ret

;--------------------------------------
; WRITE MULTIPLE EXT (48-bit LBA)
;--------------------------------------
PIO_Write:
    push dx
    push si
    mov si, PIOData
    mov cx, [count]      ; number of sectors
    xor bx, bx           ; high byte of LBA

write_loop:
    call wait_drq

    ; High bytes for 48-bit LBA
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

    ; Low bytes (actual LBA)
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

    ; Issue WRITE MULTIPLE EXT
    mov dx, COMMAND_REG
    mov al, 0xCD
    out dx, al

    call wait_drq

    ; Stream sector via REP OUTSW
    mov dx, DATA_REG
    mov cx, 256         ; words per sector
    rep outsw

    add si, 512         ; advance pointer (bytes)
    inc bl
    dec cx
    jnz write_loop

    pop si
    pop dx
    ret

;--------------------------------------
; READ MULTIPLE EXT (48-bit LBA)
;--------------------------------------
PIO_Read:
    push dx
    push di
    mov di, PIOData
    mov cx, [count]
    xor bx, bx

read_loop:
    call wait_drq

    ; High bytes for 48-bit LBA
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

    ; Low bytes (actual LBA)
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

    ; Issue READ MULTIPLE EXT
    mov dx, COMMAND_REG
    mov al, 0x25
    out dx, al

    call wait_drq

    ; Stream sector via REP INSW
    mov dx, DATA_REG
    mov cx, 256
    rep insw

    add di, 512         ; advance pointer (bytes)
    inc bl
    dec cx
    jnz read_loop

    pop di
    pop dx
    ret
