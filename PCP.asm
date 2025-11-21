; PCP.asm - Process Control for Virtual Modes
; Handles 16-bit and 32-bit switching

section .text
global PCPEntry
PCPEntry:

    cmp ah, 0
    je PCVMRun
    cmp ah, 1
    je PCVMTerminate
    jmp PCVMDone        ; fallback if unknown

; -------------------------
; Run 16-bit mode procedure
; -------------------------
PCVMRun:
    pushf                ; save flags
    push ds              ; save ds
    push cs              ; save cs

    ; Save return address manually instead of push eip
    call PCVM16Wrapper
    ; execution returns here in 32-bit mode

    pop cs
    pop ds
    popf
    iret

; 16-bit wrapper called via call
[BITS 16]
PCVM16Wrapper:
    call edx             ; jump to 16-bit procedure
    retf                 ; far return back to 32-bit
[BITS 32]

; -------------------------
; Terminate VM
; -------------------------
PCVMTerminate:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    iret

PCVMDone:
    iret

