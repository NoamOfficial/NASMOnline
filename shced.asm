section .data
Core1:
ESP0 db 0x1FFh
EAX0 db 0
EBX0 db 0
ECX0 db 0
EDX0 db 0
CS0 db 0x02
IP0 db 0
Core2:
ESP1 db 0x4FFh
EAX1 db 0
EBX1 db 0
ECX1 db 0
EDX1 db 0
CS0 db 0x04
IP0 db 0
Core3:
ESP2 db 0x6FFh
EAX2 db 0
EBX2 db 0
ECX2 db 0
EDX2 db 0
CS2 db 0x06
IP2 db 0
Core4:
ESP3 db 0x7FFh
EAX3 db 0
EBX3 db 0
ECX3 db 0
EDX3 db 0
CS3 db 0x07
IP3 db 0
Core5:
ESP4 db 0x9FFh
EAX4 db 0
EBX4 db 0
ECX4 db 0
EDX4 db 0
CS4 db 0x09
IP4 db 0
Core6:
ESP5 dd 0x11FFh
EAX5 dd 0
EBX5 dd 0
ECX5 dd 0
EDX5 dd 0
CS5 dd 0x11
IP5 dd 0
section .text
cmp eax, 0xFB
je ChangeCoreInfo
cmp eax, 0xCA
je DisableInterrupt
