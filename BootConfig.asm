global testsigning
global useatadrivers
global OSVersion
global DataWipe
Config:
testsigning db 0
useatadrivers db 0
OSVersion dd 0x10
DataWipe db 0
DiskDriverConfig:
diskMode dw "NATA"
ControllerInLegacyMode db 0
ISDEnabled db 0
global Mode
Global diskMode
global ControllerInLegacyMode
global ISDEnabled
Entry0:
BootSectorStartingLBA dw 0
BootSectorCount dw 4
Entry1: resb 4
Entry2: resb 4
Entry3: resb 4
global Entry1
global Entry2
global Entry3
BootPolicyList:
db 00, 0F, 0B, FF, FC
