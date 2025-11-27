section .data
; ----------------------
; Core contexts
; ----------------------
CoreCount   dd 6
CurrentCore dd 0            ; index of active core

CoreESP     dd 0x1FF,0x4FF,0x6FF,0x7FF,0x9FF,0x11FF
CoreEAX     dd 0,0,0,0,0,0
CoreEBX     dd 0,0,0,0,0,0
CoreECX     dd 0,0,0,0,0,0
CoreEDX     dd 0,0,0,0,0,0
CoreEFLAGS  dd 0,0,0,0,0,0
CoreCS      dd 0x02,0x04,0x06,0x07,0x09,0x11
CoreIP      dd 0,0,0,0,0,0    ; <-- pointer to routines assigned dynamically
CoreState   db 1,1,1,1,1,1   ; 1=active, 0=sleep

; ----------------------
; Commands
; ----------------------
CMD_SWITCH_CORE equ 0xFB
CMD_DISABLE_IRQ equ 0xCA
CMD_SLEEP_CORE   equ 0xAA
CMD_WAKE_CORE    equ 0xBB
CMD_RESET_CORE   equ 0xCC
CMD_PRINT_INFO   equ 0xDD
CMD_ONE_SHOT     equ 0xEE

section .text
global Scheduler

; ----------------------
; Scheduler loop
; ----------------------
Scheduler:
    cmp eax, CMD_SWITCH_CORE
    je SwitchCore
    cmp eax, CMD_DISABLE_IRQ
    je DisableInterrupt
    cmp eax, CMD_SLEEP_CORE
    je SleepCore
    cmp eax, CMD_WAKE_CORE
    je WakeCore
    cmp eax, CMD_RESET_CORE
    je ResetCore
    cmp eax, CMD_PRINT_INFO
    je PrintCoreInfo
    cmp eax, CMD_ONE_SHOT
    je OneShotTask
    jmp Scheduler

; ----------------------
; Switch core (CALL-based)
; ----------------------
SwitchCore:
    mov ebx, [CurrentCore]

    ; save registers + flags
    pushad
    pushfd
    lea esi, [CoreEAX + ebx*4]
    mov [esi], eax
    lea esi, [CoreEBX + ebx*4]
    mov [esi], ebx
    lea esi, [CoreECX + ebx*4]
    mov [esi], ecx
    lea esi, [CoreEDX + ebx*4]
    mov [esi], edx
    lea esi, [CoreESP + ebx*4]
    mov [esi], esp
    lea esi, [CoreEFLAGS + ebx*4]
    pop eax
    mov [esi], eax

NextCore:
    inc dword [CurrentCore]
    cmp dword [CurrentCore], [CoreCount]
    jl LoadNextCore
    mov dword [CurrentCore], 0
    jmp NextCore

LoadNextCore:
    mov ebx, [CurrentCore]
    mov al, [CoreState + ebx]
    cmp al, 1
    je CoreReady
    jmp NextCore

CoreReady:
    ; restore registers + flags
    lea esi, [CoreESP + ebx*4]
    mov esp, [esi]
    lea esi, [CoreEAX + ebx*4]
    mov eax, [esi]
    lea esi, [CoreEBX + ebx*4]
    mov ebx, [esi]
    lea esi, [CoreECX + ebx*4]
    mov ecx, [esi]
    lea esi, [CoreEDX + ebx*4]
    mov edx, [esi]
    lea esi, [CoreEFLAGS + ebx*4]
    mov eax, [esi]
    push eax
    popfd

    ; call routine via CoreIP
    lea esi, [CoreIP + ebx*4]
    mov eax, [esi]
    test eax, eax
    jz Scheduler        ; skip if no routine assigned
    call eax

    jmp Scheduler

; ----------------------
; Sleep / Wake / Reset / Print / OneShot
; ----------------------
SleepCore:
    mov ebx, [CurrentCore]
    mov byte [CoreState + ebx], 0
    jmp Scheduler

WakeCore:
    mov ebx, [CurrentCore]
    mov byte [CoreState + ebx], 1
    jmp Scheduler

ResetCore:
    mov ebx, [CurrentCore]
    lea esi, [CoreEAX + ebx*4]
    mov dword [esi], 0
    lea esi, [CoreEBX + ebx*4]
    mov dword [esi], 0
    lea esi, [CoreECX + ebx*4]
    mov dword [esi], 0
    lea esi, [CoreEDX + ebx*4]
    mov dword [esi], 0
    lea esi, [CoreESP + ebx*4]
    mov dword [esi], 0
    lea esi, [CoreEFLAGS + ebx*4]
    mov dword [esi], 0
    jmp Scheduler

PrintCoreInfo:
    ; placeholder: implement printing to VGA / debug port
    jmp Scheduler

OneShotTask:
    sti                  ; enable interrupts
    push ss              ; push current stack segment
    ; optionally: push ESP/EIP or call a one-shot routine
    jmp Scheduler

DisableInterrupt:
    cli
    hlt

