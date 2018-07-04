print_string:
    pusha                   ; Store all registers so we can restore them later
    mov ah, 0x0e            ; int=10/ah=0x0e -> BIOS tele-type output

print_string_loop:
    mov al, [bx]            ; Move the current character into al
    cmp al, 0               ; Check to see if it's not 0
    je print_string_end     ; If it is, jump to end
    int 0x10                ; Print ( al ) to the screen
    inc bx                  ; Increment bx to point at the next character
    jmp print_string_loop   ; Jump to the front of the loop

print_string_end:
    mov al, 0x0d            ; Add a carriage return
    int 0x10
    mov al, 0x0a            ; Add a newline
    int 0x10
    popa                    ; Restore the original registers
    ret