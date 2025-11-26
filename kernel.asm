section .data
vgaBase dd 0xB0000
vgaLimit dd 0xBFFFF
y dw 0
x dw 0
Char db 0
color db 0
section .text
main:
mov es, [0x01]
mov edi, 0
stosw
cmp al, "kp"
je BugCheck
push esp
push ebp
cmp dl, "i"
je HandleInterrupt
HandleInterrupt:
mov al, dh
mov bx, 4
mul bx 
jmp main
vgaPrint:
mov ax, vgaBase
mov es, ax

mov bx, y
mov dx, 80
mul dx        ; ax = y * 80

add ax, x     ; ax = y*80 + x
shl ax, 1     ; ax *= 2 -> final offset

mov edi, ax
mov al, Char
mov ah, color
stosw         ; write to ES:DI
global x
global y
global vgaPrint
global color
global Char
BugCheck:
BugCheckString dq "UltimateOS had Terminated because of a kernel panic, we'll restart for you"
mov ds, [BugCheckString]
mov si, 0
loop:
mov eax, [0xB0000]
mov edi, 0
mov [eax:edi], [ds:si]
add edi, 2
cmp [ds:si], 0
jne loop
je ResetAfterCrash:
ResetAfterCrash:
cli
in al, 0x92
or al, 000000b1
out 0x92, al

global vgaPrint
global x
global y
global color
global Char




