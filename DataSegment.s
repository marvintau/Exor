InputBufferLength:
    .quad   10 
    .byte   0x20
InputBuffer:
    .ascii    "TestWordS "
    .fill     64, 1, 0x20 
InputBufferEnd:

Stack:
    .rept    16   
    .quad    0
    .endr
StackEnd:
