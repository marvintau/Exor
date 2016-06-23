InputBufferLength:
    .quad   15 
    .byte   0x20
InputBuffer:
    .ascii    "TestBranch 2"
    .fill     64, 1, 0x20 
InputBufferEnd:

QuitRoutineHolder:
    .quad    0

Stack:
    .rept    16   
    .quad    0
    .endr
StackEnd:

DataStack:
    .rept    16
    .quad    0
    .endr
DataStackEnd:
