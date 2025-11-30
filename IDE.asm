section .data
PIOData: 
data1 resb 256
data2 resb 256
data3 resb 256
data4 resb 256
count db 0
SECTOR_COUNT EQU 0x1F5
DATA_REG EQU 0x1F0
COMMAND_REG EQU 0x1F7
STATUS_REG EQU 0x1F7
global data1
global PIOData
global data2
global data3
global data4
global count
section .text
cmp ah, 0x00
je Write
cmp ah, 0x01
je Read
Write:
in ax, STATUS_REG
test ax, 0x88
jz Write_loop
Writeloop:
mov al, 0x39
mov dx, 0x1F7
out dx, al
mov ax, count
push ax
mov al, ah
mov dx, 0x1F2
out dx, al
pop ax
mov dx, 0x1F2
out dx, al
mov ax, bx
mov dx, 0x1F3
out dx, al
mov dx, 0x1F4
xchg al, ah
out dx, al
cld
mov si, [PIOData]
mov cx, 1024
mov dx, 0x1F0
writefast:
REP LODSB
OUTSW
jnz writefast
jz Done
Read:
in al, 0x1F7
test al, 0x88
jz readloop
readloop:
mov al, 0x24
out 0x1F7, al
mov ax, bx
out 0x1F3, al
xchg al, ah
out 0x1F4, al
mov dx, 0x1F0
mov si, [PIOData]
mov cx, 1024
rep lodsb
readsectors:
outsw
jnc readsectors
jc Done
Done:
iret








