section .data
vgaBase dd 0xB0000
vgaLimit dd 0xBFFFF
y dw 0
x dw 0
Char db 0
color db 0
section .text
main:
MOV ES, 0x01
mov di, 0
stosw
cmp al, kp
je BugCheck
push esp
push ebp
cmp dl, "i"
je HandleInterrupt
HandleInterrupt:
mov al, dh
mov bx, 4
mult bx 
jmp main
vgaPrint:
mov ax, vgaBase
mov es, ax

mov bx, y
mov dx, 80
mul dx        ; ax = y * 80

add ax, x     ; ax = y*80 + x
shl ax, 1     ; ax *= 2 -> final offset

mov di, ax
mov al, Char
mov ah, color
stosw         ; write to ES:DI
global x
global y
global vgaPrint
global color
global Char



