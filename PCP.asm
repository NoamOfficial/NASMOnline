cmp ah, 0
je PCVMRun
cmp ah, 1
je PCVMTerminate
jmp PCVMDone            ; if unknown

; -------------------------
; Run 16-bit mode procedure
; -------------------------
PCVMRun:
    pushf                ; save flags
    push ds              ; save ds
    push cs              ; save cs
    push ip              ; save ip (NASM replaces it properly)

    [BITS 16]
    call edx             ; run 16-bit code
    [BITS 32]

    ; restore state
    pop ip
    pop cs
    pop ds
    popf

    iret

; -------------------------
; Terminate VM
; -------------------------
PCVMTerminate:
    ; zero registers (optional)
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    iret

PCVMDone:
    iret

