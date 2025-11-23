INCLUDE "VirtMem.inc"


MOV DS, 0x09
loop:
mov edx, 0
inc edx
MOVVA edx, ebx
jz loop
