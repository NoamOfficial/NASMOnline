; PCP.asm - Process Control for Virtual Modes (PCVM)
; Fully NASM-clean, 16/32-bit switch, no obsolete instructions

section .text
global PCPEntry
PCPEntry:

    cmp ah, 0
    je PCVMRun
    cmp ah, 1
    je PCVMTerminate
    jmp PCVMDone         ; fallback if unknown

; -------------------------
; Run 16-bit mode procedure
; -------------------------
PCVMRun:
    pushf                ; save flags
    push ds              ; save ds

    ; Call 16-bit wrapper (EDX points to 16-bit procedure)
    call PCVM16Wrapper
    ; execution returns here in 32-bit mode

    pop ds
    popf
    iret

; -------------------------
; 16-bit wrapper
; -------------------------
[BITS 16]
PCVM16Wrapper:
    call edx             ; run 16-bit code
    retf                  ; far return back to 32-bit
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


