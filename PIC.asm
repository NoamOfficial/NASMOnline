DeviceInfo:
Vendor dw 0
StatusMMIO dd 0
DataMMIO dd 0
IsPort db 0
Portlist dd 0, 0, 0, 0, 0, 0, 0, 0
Section .text
mov eax, Vendor
jc VendorInvalid
mov es, [0x4000]
mov di, 0
mov ds, [0x8000]
mov si, 0
rep movsb
cmp [0x4001], 0xFFFF
je VendorInvalid
cmp [StatusMMIO], 1
je HandleIRQ
HandleIRQ:
mov eax, 0x4000
mul edx
push edx
push eax
pop eax
movz edx, 15
cmp edx, [esp]
je JMPHandler
JMPHandler:
pop edx
callf eax:0
iret
VendorInvalid:
hlt





