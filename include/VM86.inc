;========================================
; VM86.inc - VM86 Mode Macros w/ BIOS call support
; CPU: 386+, No Paging
; Author: Noam
;========================================

%ifndef VM86_INC
%define VM86_INC

;------------------------------------------------
; VM86 Stack location (adjustable)
;------------------------------------------------
VM86_STACK    equ 0x7000   ; VM86 stack top
VM86_STACK_SIZE equ 0x1000 ; stack size 4KB

;------------------------------------------------
; ENTER_VM86
; Prepares CPU to execute VM86
; Sets VM flag in EFLAGS, initializes stack
;------------------------------------------------
%macro ENTER_VM86 0
    cli                 ; disable interrupts
    pushfd              ; save EFLAGS
    push eax            ; save registers as needed

    ; set VM flag in EFLAGS
    pushfd
    pop eax
    or eax, 1<<17
    push eax
    popfd

    ; setup VM86 stack
    mov ss, ax
    mov esp, VM86_STACK
    sti                 ; enable interrupts
%endmacro

;------------------------------------------------
; EXIT_VM86
; Return to protected mode
;------------------------------------------------
%macro EXIT_VM86 0
    cli
    ; clear VM flag
    pushfd
    pop eax
    and eax, 0xFFFEFFFF
    push eax
    popfd

    pop eax
    popfd
    sti
%endmacro

;------------------------------------------------
; VM86_SETSegs cs, ds, es, ss
; Setup segment registers for VM86
;------------------------------------------------
%macro VM86_SETSegs 4
    mov ax, %1
    mov cs, ax
    mov ax, %2
    mov ds, ax
    mov ax, %3
    mov es, ax
    mov ax, %4
    mov ss, ax
%endmacro

;------------------------------------------------
; VM86_INT int_num
; Call BIOS/DOS interrupt in VM86
; Usage: VM86_INT 0x10
;------------------------------------------------
%macro VM86_INT 1
    ; save current stack
    push esp
    push ss
    pushad

    ; VM86 call
    int %1

    ; restore stack
    popad
    pop ss
    pop esp
%endmacro

;------------------------------------------------
; VM86_SETUP_BUFFER addr, size
; Setup a temporary real-mode buffer
;------------------------------------------------
%macro VM86_SETUP_BUFFER 2
    mov eax, %1        ; buffer address
    mov ecx, %2        ; buffer size
    ; optionally, initialize memory here
%endmacro

%endif
