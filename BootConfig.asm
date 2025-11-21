global BootConfig
global testsigning
global useatadrivers
global OSVersion
global DataWipe
global diskMode
global ControllerInLegacyMode
global ISDEnabled
global Mode
global Entry0
global Entry1
global Entry2
global Entry3

section .bss
BootConfig:                   ; start of contiguous struct
    ; ------------------- Config -------------------
    testsigning          resb 1
    useatadrivers        resb 1
    OSVersion            resd 1          ; 4 bytes
    DataWipe             resb 1
    align 4                               ; pad to 4-byte boundary

    ; ---------------- DiskDriverConfig -------------
    diskMode             resd 1          ; 4 bytes for ASCII 'NATA'
    ControllerInLegacyMode resb 1
    ISDEnabled           resb 1
    align 4                               ; pad to 4-byte boundary

    ; ---------------- Mode ------------------------
    Mode                 resb 1
    align 4                               ; pad to 4-byte boundary

    ; ---------------- Boot Entries -----------------
Entry0:
    BootSectorStartingLBA  resw 1        ; 2 bytes
    BootSectorCount        resw 1        ; 2 bytes
    align 4                               ; pad for 32-bit Entry1

Entry1: 
    resd 1                               ; 4 bytes
Entry2: 
    resd 1                               ; 4 bytes
Entry3: 
    resd 1                               ; 4 bytes


