
# Before adding new entry to memory, we suppose that
# we have get the new word bound. Thus AddEntryHeader
# should be called in another word with LocateWordBound
# called right before.

# Note that after the LocateWordBound being called, the
# register EndReg (%r9) remains same, yet StartReg (%r8)
# stores the length of the string.

Code AddEntryHeader    
    push %rax
    push %rcx
    
    

    pop  %rcx
    pop  %rax
CodeEnd AddEntryHeader

Code AddEntryEnd
CodeEnd AddEntryEnd
