%macro ERDTSC 0
    mov     al, 0
    out     0x43, al

    in      al, 0x40
    in      ah, 0x40

    not     ax        ; turn countdown into count-up
%endmacro
