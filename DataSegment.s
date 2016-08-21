# For Debug purpose
EvaluationLevel:
    .quad 0

# The starting address of dictionary will be altered
# when new entries are added. Thus the FindEntry routine
# should start searching by reading in the new starting
# address of dictionary instead of a fixed one.
DictionaryStartAddress:
   .quad DictStart 


# Since the lexer will not only read the string
# buffer from user input, but might also read
# from program-created buffer, we will be reading
# the Buffer address from this BufferAddressRegister
BufferAddressRegister:
    .quad   InputBuffer

# WordBounding will operate this.
WordStartOffset:
    .quad   0
WordLength:
    .quad   0
WordCount:
    .quad   0

InputBufferLength:
    .quad   40 
    .byte   0x20
InputBuffer:
    .ascii    "Compile"
    .fill     64, 1, 0x20 
InputBufferEnd:

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
