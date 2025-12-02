section .data
PS2_CMD EQU 0x64
PS2_DATA EQU 0x60
x db 0
y db 0
col db 40
row db 12
left db 0
right db 0
section .bss
DataBuffer: resb 8192
section .text
cmp ah, 0x01
je GetKey
cmp ah, 0x02
je WaitUntilKey
cmp ah, 0x03
je GetXYZ
cmp ah, 0x04
je DisableScan
cmp ah, 0x05
je Send_byte
cmp ah, 0x06
je send_cmd
cmp ah, 0x07
je receive_byte
iret
GetKey:
mov dx, PS2_CMD
mov al, 0xF4
out dx, al
mov dx, PS2_DATA
in al, dx
iret
WaitUntilKey:
mov dx, PS2_CMD
mov al, 0xF4
out dx, al
checkKey:
mov dx, PS2_DATA
in al, dx
cmp al, 0x00
je CheckKey
iret
GetXYZ:
poll_mouse:
    ; Wait for first byte (buttons)
.wait_byte1:
    in al, 0x64
    test al, 1
    jz .wait_byte1
    in al, 0x60
    mov bl, al        ; save buttons

    ; Wait for X movement
.wait_x:
    in al, 0x64
    test al, 1
    jz .wait_x
    in al, 0x60
    mov [x], al

    ; Wait for Y movement
.wait_y:
    in al, 0x64
    test al, 1
    jz .wait_y
    in al, 0x60
    mov [y], al

    ; Parse buttons
    mov al, bl
    and al, 1
    mov [left], al
    mov al, bl
    shr al, 1
    and al, 1
    mov [right], al

    ret

; ------------------------------
; Update Cursor (Smooth X/Y → text-mode coordinates)
; ------------------------------
update_cursor:
    ; --- Apply smoothed X movement ---
    movsx ax, byte [x]
    cdq
    mov bx, smooth_factor
    idiv bx                 ; divide delta by smoothing factor
    add [col], al
    cmp byte [col], 0
    jge .x_min_done
    mov byte [col], 0
.x_min_done:
    cmp byte [col], 40-1
    jle .x_done
    mov byte [col], 40-1
.x_done:

    ; --- Apply smoothed Y movement ---
    movsx ax, byte [y]
    cdq
    mov bx, 1
    idiv bx                 ; divide delta by smoothing factor
    sub [row], al    ; invert Y
    cmp byte [row], 0
    jge .y_min_done
    mov byte [row], 0
.y_min_done:
    cmp byte [row], 40-1
    jle .y_done
    mov byte [row], 40-1
.y_done:

    ; --- Compute internal text-mode offset (LEA trick) ---
    mov al, [row]
    xor ah, ah
    lea di, [eax*128 + eax*32]  ; row*160
    mov al, [col]
    lea di, [di + eax*2]        ; row*160 + col*2
    ; DI now holds virtual offset; can be used internally
    ret
Send_cmd:
mov dx, PS2_CMD
out dx, al
ret
send_byte:
mov dx, PS2_DATA
out dx, al
ret
receive_byte:
mov dx, PS2_DATA
in al, dx
ret
global x
global y
global left
global right











