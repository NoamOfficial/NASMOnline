bits 32

section .bss
align 4
RAX        resq 1          ; 64-bit LBA storage (low + high)
RXX        resq 1          ; temporary 64-bit if needed
Buffer     resw 2048        ; 2048 words = 4096 bytes
SectorCount resb 1          ; number of sectors
Operation  resb 1           ; 0 = WRITE, 1 = READ

section .text
global IDE_PIO_STREAM_FINAL

IDE_PIO_STREAM_FINAL:

    cmp byte [Operation], 0
    je .write
    cmp byte [Operation], 1
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

    mov esi, Buffer        ; source pointer
    mov ecx, [SectorCount] ; number of sectors

.write_sector_loop:
    call Wait_DRQ
    mov dx, 0x1F0
    mov ebx, 256           ; words per sector

.write_loop:
    o16 lodsw               ; load 16-bit from [DS:ESI] -> AX
    out dx, ax              ; write word to port DX
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
    mov ecx, [SectorCount]

.read_sector_loop:
    call Wait_DRQ
    mov dx, 0x1F0
    mov ebx, 256

.read_loop:
    in ax, dx
    o16 stosw               ; store word from AX -> [ES:EDI]
    dec ebx
    jnz .read_loop

    dec ecx
    jnz .read_sector_loop
    ret

; ==================================================
; ============== 48-BIT LBA SETUP =================
; ==================================================
Setup_LBA48_Multi:

    ; Load LBA from memory slots
    mov eax, dword [RAX]       ; low 32 bits
    mov edx, dword [RAX+4]     ; high 32 bits (upper 16 bits used for 48-bit LBA)

    ; Sector count
    mov dx, 0x1F2
    mov al, [SectorCount]
    out dx, al

    ; --- LBA low/mid/high (first 24 bits) ---
    mov dx, 0x1F3
    mov al, al
    out dx, al
    mov dx, 0x1F4
    mov al, ah
    out dx, al
    mov dx, 0x1F5
    mov al, dl
    out dx, al

    ; --- LBA high/mid/high (next 24 bits) ---
    mov dx, 0x1F2
    mov al, dh
    out dx, al
    mov dx, 0x1F3
    shr edx, 8
    mov al, dh
    out dx, al
    mov dx, 0x1F4
    shr edx, 16
    mov al, dh
    out dx, al
    mov dx, 0x1F5
    shr edx, 24
    mov al, dh
    out dx, al

    ; Master + LBA mode
    mov dx, 0x1F6
    mov al, 0x40
    out dx, al

    ret

; ==================================================
; ================= STATUS WAIT ===================
; ==================================================
Wait_DRQ:
    mov dx, 0x1F7
.wait_bsy:
    in al, dx
    call Wait_420ns
    test al, 0x80          ; BSY
    jnz .wait_bsy

.wait_drq:
    in al, dx
    call Wait_420ns
    test al, 0x08          ; DRQ
    jnz .ready
    test al, 0x01          ; ERR
    jnz .error
    jmp .wait_drq

.ready:
    ret
.error:
    ret

; ==================================================
; ================= 420ns DELAY ===================
; ==================================================
Wait_420ns:
    mov dx, 0x1F7
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    ret
