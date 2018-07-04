print_hex:                  ; Print the hexadecimal number that is located in dx
    pusha                   ; Store all our registers
    mov si, HEX_OUT + 5     ; Point si to the last 0 in the string

print_hex_character:
    mov bl, dl              ; Grab the 4 lowest bits in dx
    shr dx, 4               ; Move those 4 bits off of dx
    and bl, 0xf             ; And make sure we only have the lowest 4 bits

    ; Now, bl can be either of 2 values:
    ; 0-9: we just add '0' (0x30)
    ; A-F: we add 'A' - 10 (0x37)
    ; To simplify this, we always add 0x30, and check if bl >= 0xA, then we add 0x07

    add bl, 0x30            ; Add 0x30
    cmp bl, 0x3a            ; Check to see if we're A-F
    jl skip_hex_character   ; If dl is not A-F, skip adding 0x07
    add bl, 0x07
skip_hex_character:
    mov [si], bl            ; Move bl to the HEX_OUT string
    dec si                  ; Move si to the left

    cmp si, HEX_OUT + 1     ; If si is pointing after 0x0000, we're done
    jne print_hex_character ; else we jump back

    mov bx, HEX_OUT         ; Move the address of HEX_OUT into bx
    call print_string       ; And print HEX_OUT

    popa                    ; Restore the registers
    ret

HEX_OUT: db '0x0000',0