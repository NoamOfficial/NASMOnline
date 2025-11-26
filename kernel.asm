BITS 32

section .data
vgaBase        dd 0xB8000
x              dw 0
y              dw 0
Char           db 0
color          db 0x0F

IDTAddress     dd 0           ; store IDT base here

BugCheckString db "UltimateOS had Terminated because of a kernel panic, we'll restart for you", 0

VGA_WIDTH      equ 80
VGA_HEIGHT     equ 25

section .text
global main
global vgaPrint
global BugCheck
global ResetAfterCrash
global HandleInterrupt

; =============================
; KERNEL ENTRY POINT
; =============================
main:
    cli
    mov eax, vgaBase
    mov edi, 0
    sti

kernel_loop:
    
    cmp al, 'k'
    je BugCheck
    cmp al, 'i'
    je HandleInterrupt
    jmp kernel_loop

; =============================
; INTERRUPT HANDLER
; Returns: EAX = IDT base + (InterruptNumber*4)
; =============================
HandleInterrupt:
    ; Load IDT base
    lea edi, [IDTAddress]
    sidt [edi]                ; 6 bytes: 2-byte limit, 4-byte base
    mov eax, [IDTAddress+2]   ; get 32-bit base address of IDT

    ; AL = interrupt number (passed somehow by your kernel)
    ; Multiply interrupt number by 4
    movzx ebx, al             ; EBX = interrupt number
    shl ebx, 2                ; multiply by 4

    add eax, ebx              ; EAX = IDTBase + interrupt_number*4
    ret

; =============================
; VGA PRINT WITH SCROLL & WRAP
; =============================
vgaPrint:
    movzx ebx, word [y]
    imul ebx, VGA_WIDTH
    movzx edx, word [x]
    add ebx, edx
    shl ebx, 1
    mov edi, ebx
    add edi, vgaBase

    mov al, [Char]
    mov ah, [color]
    stosw

    ; Advance cursor
    inc word [x]
    cmp word [x], VGA_WIDTH
    jb .done

    mov word [x], 0
    inc word [y]

    cmp word [y], VGA_HEIGHT
    jb .done

    ; Scroll up
    mov esi, vgaBase
    add esi, 2 * VGA_WIDTH
    mov edi, vgaBase
    mov ecx, 2 * VGA_WIDTH * (VGA_HEIGHT - 1)
    rep movsb

    ; Clear last row
    mov ecx, VGA_WIDTH
    xor eax, eax
.clear_last_row:
    mov [edi + ecx*2 - 2], ax
    loop .clear_last_row

    dec word [y]

.done:
    ret

; =============================
; BUG CHECK
; =============================
BugCheck:
    mov esi, BugCheckString
    mov edi, vgaBase

.print_loop:
    lodsb
    cmp al, 0
    je ResetAfterCrash
    mov [Char], al
    call vgaPrint
    jmp .print_loop

; =============================
; RESET ROUTINE
; =============================
ResetAfterCrash:
    cli
    in al, 0x92
    or al, 0b00000001
    out 0x92, al
    hlt





