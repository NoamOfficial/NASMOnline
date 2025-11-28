section .data
MFTBase dd 0x02
FileStart resd 8
section .text
WriteFile:
MOV AH, 0
MOV DX, FileStart
callf SET_SECTOR_NUM_32
int 13h
ret
ReadFile:
MOV AH, 1
MOV DX, FileStart
int 13h
ret
global ReadFile
global WriteFile

