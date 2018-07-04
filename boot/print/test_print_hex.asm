[org 0x7c00]
    mov dx, 0x1234
    call print_hex
    jmp $

%include "print_string.asm"
%include "print_hex.asm"

times 510-($-$$) db 0
dw 0xaa55
