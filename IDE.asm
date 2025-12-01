section .bss
PIOData:
StartLBA resd 1
Data resw 2048
Operation db 0
global PIOData
global StartLBA
global Data
global Operation
dw HIGH 0
dw LOW 0
dw MID 0
section .text
Check:
mov dx, 0x1F7
in al, dx    ; read status
test al, 0x80        ; check BSY
jnz busy_wait        ; BSY=1 -> wait

test al, 0x40        ; check DRDY
jz not_ready         ; DRDY=0 -> not ready

test al, 0x08        ; check DRQ
jz wait_drq          ; DRQ=0 -> wait for data

GroupLBA:
mov eax, [StartLBA]
mov dl, al            ; LOW_L  = bits 0-7
mov dh, ah            ; LOW_H  = bits 8-15
mov bl, al            ; MID_L  = bits 16-23
mov bh, ah            ; MID_H  = bits 24-31
xor cl, cl            ; HIGH_L = 0 (since LBA < 2^32)
xor ch, ch            ; HIGH_H = 0
push dh
push dl
Run_Command:
cmp [Operation], 0x00
je Write
cmp [Operation], 0x01
je Read
Write:
pop al
mov dx, 0x1F2
out dx, al
pop al
mov dx, 0x1F3
out dx, al
mov al, bl
mov dx, 0x1F4
out dx, al
mov al, bh
mov dx, 0x1F5
out dx, al
mov dx, 0x1F7
mov al, 0x24
out dx, al
mov dx, 0x1F0
mov si, [Data]
mov cx, 2048
loop_write:
outsw
inc di
check_sector:
cmp di, 512
je preload
cmp di, 2048
je Done
preload:
push cx
mov cx, 512
mov es, [Data]
push di
mov di, 512
rep lodsb
pop di
pop cx
jmp loop_write
wait_drq:
test al, 0x08
jnz Run_Command
jz wait_drq
not_ready:
test al, 0x40
jnz Run_Command
jz not_ready
busy_wait:
test al, 0x80
jnz Run_Command
jz busy_wait
Read:
pop al
mov dx, 0x1F2
out dx, al
pop al
mov dx, 0x1F3
out dx, al
mov dx, 0x1F4
mov al, bl
out dx, al
mov dx, 0x1F5
mov al, bh
out dx, al
mov dx, 0x1F0
mov es, [Data]
mov di, 0
OutReadData:
outsw
inc di
cmp di, 2048
je Done
jmp OutReadData
Done:
ret

