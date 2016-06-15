InputBufferLength:
    .quad   12 
    .byte   0x20
InputBuffer:
    .ascii    "JesusWord"
    .fill     64, 1, 0x20 
InputBufferEnd:

QuitRoutineHolder:
    .quad    0

Stack:
    .rept    16   
    .quad    0
    .endr
StackEnd:
