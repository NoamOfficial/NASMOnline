%macro MOVVA 2
MOV ES, DS
MOV DI, %1
MOV AX, %2
STOSW
%endmacro
%macro STOVA 1
MOV ES, DS
MOV DI, %1
STOSW
%endmacro
%macro LODVA 1
MOV ES, DS
MOV DI, %1
LODSW

