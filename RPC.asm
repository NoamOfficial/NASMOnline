section .bss
RPCData      resd 2        ; 8 bytes for command
RPCmemory    resb 65335    ; buffer
RPCWriteData resb 1024     ; write buffer

global RPCWriteData
global RPCData
global RPCHandler

section .text
RPCHandler:

    ; ------------------------
    ; Load command from RPCData
    ; ------------------------
    mov eax, [RPCData]      ; load first 4 bytes
    cmp eax, 'WRT'          ; write command
    je WRITEMESSAGE
    cmp eax, 'READ'         ; read command
    je READRPC
    cmp eax, 'CHCL'         ; first 4 chars of "CHCLR"
    je CacheClear
    jmp RPCDone             ; unknown command

; ------------------------
; Write message
; ------------------------
WRITEMESSAGE:
    xor esi, esi            ; index in RPCWriteData
    xor edi, edi            ; index in RPCmemory
WRITE_LOOP:
    mov al, [RPCWriteData + esi]
    cmp al, 0               ; stop at null
    je WRITE_DONE
    mov [RPCmemory + edi], al
    inc esi
    inc edi
    jmp WRITE_LOOP
WRITE_DONE:
    jmp RPCDone

; ------------------------
; Clear write buffer
; ------------------------
CacheClear:
    mov ecx, 1024
    mov edi, RPCWriteData
    xor eax, eax
    rep stosb                ; zero RPCWriteData
    jmp RPCDone

; ------------------------
; Read RPC
; ------------------------
READRPC:
    mov al, [RPCmemory]     ; read first byte
    mov bl, [RPCmemory + 1]
    mov bh, [RPCmemory + 2]
    mov dl, [RPCmemory + 3]
    ; further processing here
    jmp RPCDone

RPCDone:
    iret




