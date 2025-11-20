cmp ah, 0
je PCVMRun
cmp ah, 1
je PCVMTerminate
PCVMRun:
push ip
push cs
push ds
push EFLAGS
[BITS 16]
call edx
[BITS 32]
IRET
PCVMTerminate:
pop eax
pop ebx
pop ecx
pop edx
mov ecx, 0
mov eax, 0
mov ebx, 0
mov edx, 0
IRET
