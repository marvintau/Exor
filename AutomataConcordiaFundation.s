.macro ConvertStringToInteger BufferPointer, BufferLength
    push %rcx
    push %r13
    push %r14
    push %r15

    leaq BufferPointer(%rip), %r13
    movq BufferLength(%rip),  %rcx

    ForEachDigits_Convert:
        mul    $(10),   %r14
        movzbq (%r13),  %r15
        subq   $(0x30), %r15
        addq   %r15,    %r14
        addq   $(1),    %r13
    loop ForEachDigits_Convert

    # Return stack is yet to be implemented.
    PushStack

    pop  %r15
    pop  %r14
    pop  %r13
    pop  %rcx
.endm

.macro Integer
    Integer:
        call MatchNumber
        leaq IntegerCheckDone(%rip), %r13
        jmp  MatchDone
    
    IntegerCheckDone:
        .quad (IntegerCheckDone - Integer)
        .quad EntryType.Code

        
.endm
