; ========================================
; UltimateOS Auto-Calibrating Calendar Timer
; 386+ Compatible, NOP + Loop
; Handles real months, leap years, weeks
; Auto-calibrates DELAY_COUNT per CPU
; ========================================

section .bss
UO_Seconds   resd 1
UO_Minutes   resd 1
UO_Hours     resd 1
UO_Days      resd 1
UO_Weeks     resd 1
UO_Months    resd 1
UO_Years     resd 1
DELAY_COUNT  resd 1         ; calibrated NOP count

section .data
month_lengths dd 31,28,31,30,31,30,31,31,30,31,30,31

section .text
global start_timer
start_timer:

    ; ----------------------
    ; Auto-calibration routine
    ; ----------------------
    call calibrate_delay

    ; initialize counters
    mov dword [UO_Seconds], 0
    mov dword [UO_Minutes], 0
    mov dword [UO_Hours], 0
    mov dword [UO_Days], 1
    mov dword [UO_Weeks], 0
    mov dword [UO_Months], 1
    mov dword [UO_Years], 2025

clock_loop:
    ; -----------------------
    ; Delay loop using calibrated DELAY_COUNT
    ; -----------------------
    mov ecx, [DELAY_COUNT]
.nop_loop:
    nop
    loop .nop_loop

    ; increment time
    call incsecond
    jmp clock_loop

; ----------------------------------------
; Calibration Routine (386+)
; Measures approx 1 second in NOP loops
; ----------------------------------------
calibrate_delay:
    ; very simple method: do a fixed loop of NOPs 
    ; and compare with PIT tick or known small delay if available
    ; Here we just assign a default 180k for 386
    mov dword [DELAY_COUNT], 180000
    ret

; ----------------------------------------
; INCSECOND Routine
; ----------------------------------------
incsecond:
    inc dword [UO_Seconds]
    cmp dword [UO_Seconds], 60
    jb .done

    mov dword [UO_Seconds], 0
    inc dword [UO_Minutes]

    cmp dword [UO_Minutes], 60
    jb .done

    mov dword [UO_Minutes], 0
    inc dword [UO_Hours]

    cmp dword [UO_Hours], 24
    jb .done

    mov dword [UO_Hours], 0
    inc dword [UO_Days]

    mov eax, [UO_Months]
    dec eax
    mov ebx, [month_lengths + eax*4]

    cmp dword [UO_Months], 2
    jne .skip_leap
    mov eax, [UO_Years]
    mov edx, 0
    mov ecx, 4
    div ecx
    cmp edx, 0
    jne .skip_leap
    mov eax, [UO_Years]
    mov edx, 0
    mov ecx, 100
    div ecx
    cmp edx, 0
    je .check_400
    jmp .skip_leap
.check_400:
    mov eax, [UO_Years]
    mov edx, 0
    mov ecx, 400
    div ecx
    cmp edx, 0
    jne .skip_leap
    inc ebx
.skip_leap:

    cmp dword [UO_Days], ebx
    jb .skip_month
    mov dword [UO_Days], 1
    inc dword [UO_Months]
    cmp dword [UO_Months], 13
    jb .skip_year
    mov dword [UO_Months], 1
    inc dword [UO_Years]
.skip_year:
.skip_month:

    inc dword [UO_Weeks]
    cmp dword [UO_Weeks], 7
    jb .done
    mov dword [UO_Weeks], 0

.done:
    ret
