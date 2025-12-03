
section .bss
align 4
StartLBA    resq 1        ; 48-bit LBA
Buffer      resw 2048      ; 2048 words = 4096 bytes

section .text
global IDE_PIO_STREAM_MAX

IDE_PIO_STREAM_MAX:

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

    call Send_LBA48_And_Count_Stream
    mov dx, 0x1F7
    mov al, 0xEA          ; WRITE STREAM EXT
    out dx, al

    mov si, Buffer
    mov cx, 2048 / 256     ; 8 blocks of 256 words

.write_block:
    call Wait_DRQ
    mov dx, 0x1F0
    mov bx, 256
.write_loop:
    lodsw
    out dx, ax
    dec bx
    jnz .write_loop

    loop .write_block
    ret

; ==================================================
; ================= READ STREAM ===================
; ==================================================
.read:

    call Send_LBA48_And_Count_Stream
    mov dx, 0x1F7
    mov al, 0x25          ; READ STREAM EXT
    out dx, al

    mov di, Buffer
    mov cx, 2048 / 256     ; 8 blocks of 256 words

.read_block:
    call Wait_DRQ
    mov dx, 0x1F0
    mov bx, 256
.read_loop:
    insw
    mov [di], ax
    add di, 2
    dec bx
    jnz .read_loop

    loop .read_block
    ret

; ==================================================
; ================= LBA48 + SECTOR COUNT ==========
; ==================================================
Send_LBA48_And_Count_Stream:

    mov rax, [StartLBA]

    ; Send sector count = 1 (adjustable)
    mov dx, 0x1F2
    mov al, 1
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
