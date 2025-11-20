;========================================================
; ATA PIO Write Helper (ata_pio_write.inc)
; For x86 Assembly (NASM)
;========================================================

;-----------------------------
; ATA Primary Port Base
;-----------------------------
ATA_BASE        equ 0x1F0       ; Primary ATA base I/O port
ATA_CTRL        equ 0x3F6       ; Alternate status / control

;-----------------------------
; ATA Register Offsets
;-----------------------------
ATA_REG_DATA        equ 0x0
ATA_REG_ERROR       equ 0x1        ; read
ATA_REG_FEATURES    equ 0x1        ; write
ATA_REG_SECCOUNT    equ 0x2
ATA_REG_LBA_LOW     equ 0x3
ATA_REG_LBA_MID     equ 0x4
ATA_REG_LBA_HIGH    equ 0x5
ATA_REG_DRIVE       equ 0x6
ATA_REG_STATUS      equ 0x7        ; read
ATA_REG_COMMAND     equ 0x7        ; write

;-----------------------------
; ATA Status Bits
;-----------------------------
ATA_STATUS_BSY      equ 0x80
ATA_STATUS_DRDY     equ 0x40
ATA_STATUS_DF       equ 0x20
ATA_STATUS_DSC      equ 0x10
ATA_STATUS_DRQ      equ 0x08
ATA_STATUS_CORR     equ 0x04
ATA_STATUS_IDX      equ 0x02
ATA_STATUS_ERR      equ 0x01

;-----------------------------
; ATA Commands
;-----------------------------
ATA_CMD_WRITE_SECTORS      equ 0x30
ATA_CMD_WRITE_SECTORS_EXT  equ 0x34   ; 48-bit LBA

;-----------------------------
; Macros / Helper Routines
;-----------------------------

; Wait until BSY=0 and DRQ=0
%macro ATA_WAIT_READY 0
.wait:
    in al, ATA_BASE + ATA_REG_STATUS
    test al, ATA_STATUS_BSY
    jnz .wait
    test al, ATA_STATUS_DRQ
    jnz .wait
%endmacro

; Write a sector (512 bytes) from DS:SI
%macro ATA_WRITE_SECTOR 0
    mov cx, 256          ; 256 words = 512 bytes
.write_loop:
    lodsw                ; load word from DS:SI into AX
    out ATA_BASE + ATA_REG_DATA, ax
    loop .write_loop
%endmacro

;-----------------------------
; Usage Example
;-----------------------------
; mov al, 0x01          ; drive select / master
; out ATA_BASE + ATA_REG_DRIVE, al
; mov al, 0x01          ; sector count
; out ATA_BASE + ATA_REG_SECCOUNT, al
; mov al, sector_low
; out ATA_BASE + ATA_REG_LBA_LOW, al
; mov al, sector_mid
; out ATA_BASE + ATA_REG_LBA_MID, al
; mov al, sector_high
; out ATA_BASE + ATA_REG_LBA_HIGH, al
; out ATA_BASE + ATA_REG_COMMAND, ATA_CMD_WRITE_SECTORS
; ATA_WAIT_READY
; ATA_WRITE_SECTOR


