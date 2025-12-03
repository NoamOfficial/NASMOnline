bits 32

section .bss
align 4
StartLBA    resq 1        ; 48-bit LBA
Buffer      resw 2048      ; 2048 words = 4096 bytes
SectorCount resb 1         ; number of sectors to transfer

section .text
global IDE_PIO_STREAM_MULTI

IDE_PIO_STREAM_MULTI:

    ; -----------------------
    ; AH = 0x00 -> WRITE, AH = 0x01 -> READ
    ; -----------------------
    cmp ah, 0x00
    je .write
    cmp ah, 0x01
    je .read
    ret

; ==================================================
; ================= WRITE STREAM ==================
; ==================================================
.write:

    call Setup_LBA48_Multi
    mov dx, 0x1F7
    mov al, 0xEA          ; WRITE STREAM EXT
    out dx, al

    mov esi, Buffer       ; source pointer
    mov ecx, SectorCount  ; sectors to write

.write_sector_loop:
    call Wait_DRQ
    mov dx, 0x1F0
    mov ebx, 256          ; words per sector
.write_loop:
    lodsw
    out dx, ax
    dec ebx
    jnz .write_loop

    dec ecx
    jnz .write_sector_loop
    ret

; ==================================================
; ================= READ STREAM ===================
; ==================================================
.read:

    call Setup_LBA48_Multi
    mov dx, 0x1F7
    mov al, 0x25          ; READ STREAM EXT
    out dx, al

    mov edi, Buffer
    mov ecx, SectorCount

.read_sector_loop:
    call Wait_DRQ
    mov dx, 0x1F0
    mov ebx, 256
.read_loop:
    in ax, dx
    mov [edi], ax
    add edi, 2
    dec ebx
    jnz .read_loop

    dec ecx
    jnz .read_sector_loop
    ret

; ==================================================
; ================= LBA48 + MULTI-SECTOR ==========
; ==================================================
Setup_LBA48_Multi:

    mov rax, [StartLBA]

    ; sector count = SectorCount
    mov dx, 0x1F2
    mov al, [SectorCount]
    out dx, al

    ; LBA low/mid/high (first 24 bits)
    mov dx, 0x1F3
    mov al, al
    out dx, al
    mov dx, 0x1F4
    shr rax, 8
    mov al, al
    out dx, al
    mov dx, 0x1F5
    shr rax, 8
    mov al, al
    out dx, dx

    ; LBA high/mid/high (next 24 bits)
    shr rax, 8
    mov dx, 0x1F2
    mov al, al
    out dx, dx
    mov dx, 0x1F3
    shr rax, 8
    mov al, al
    out dx, dx
    mov dx, 0x1F4
    shr rax, 8
    mov al, al
    out dx, dx
    mov dx, 0x1F5
    shr rax, 8
    mov al, al
    out dx, dx

    mov dx, 0x1F6
    mov al, 0x40           ; master + LBA mode
    out dx, al

    ret

; ==================================================
; ================= STATUS WAIT ===================
; ==================================================
Wait_DRQ:
    mov dx, 0x1F7
.wait_bsy:
    in al, dx
    test al, 0x80
    jnz .wait_bsy
.wait_drq:
    in al, dx
    test al, 0x08
    jnz .ready
    test al, 0x01
    jnz .error
    jmp .wait_drq
.ready:
    ret
.error:
    ret

