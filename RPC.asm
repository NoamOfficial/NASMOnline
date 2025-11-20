RPCMessage:
RPCData resb 8
RPCmemory resb 65335
RPCWriteData resb 1024
global RPCWriteData
global RPCData
cmp RPCData, "WRT"
je WRITEMESSAGE
cmp RPCData, "CHCLR" 
cmp RPCData, "READ"
je CacheClear
WRITEMESSAGE:
MOV ES, [RPCmemory]
MOV DI, 0
MOV DS, RPCWriteData
MOV SI, 0
mov al, byte [DS:SI]
STOSB
inc si
jnc WRITEMESSAGE
CacheClear:
MOV [RPCWriteData], 0
READRPC:
MOV ES, [RPCmemory]
MOV DI, 0
STOSB
MOV BH, AL
STOSB
MOV BL, AL
STOSB
MOV DH, AL
STOSB
MOV DL, AL
IRET



