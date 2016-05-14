Number:
    .ascii "%08X\n"

InputBufferLength:
    .quad   9    
    .byte   0x20
InputBuffer:
    .ascii "All Adam"
    .fill     64, 1, 0x20 
InputBufferEnd:

ExecuteQueue:
    .rept    16 
    .quad    0
    .endr
ExecuteQueueEnd:

Stack:
    .rept    16   
    .quad    0
    .endr
StackEnd:
