.include "Lexer.s"

# Initialize LocateWord
# =====================
# r8 always stores the starting of Input buffer, yet
# r9 always stores the length of the buffer.

Code InitLocateWord
    movq BufferAddressRegister(%rip), %r8
    addq InputBufferLength(%rip), %r8
CodeEnd InitLocateWord

Code ScanInputBuffer
    movq    $SyscallRead, %rax
    movq    $(0), %rdi
    movq    BufferAddressRegister(%rip), %rsi
    movq    $(InputBufferEnd - InputBuffer), %rdx
    syscall

    decq    %rax
    movq    $(0x20), (%rsi, %rax)

    movq    %rax, InputBufferLength(%rip)
CodeEnd ScanInputBuffer

Code LocateWordBound
    LocateWordBound %r8, %r9 
CodeEnd LocateWordBound

Code MatchNumber
    MatchNumber %r8, %r9
    PushDataStack %rax
CodeEnd MatchNumber

Code ParseDecimal
    ParseDecimal %r8, %r9 
CodeEnd ParseDecimal

Code ParseHex
    ParseHex %r8, %r9
CodeEnd ParseHex

Word LiteralCheck
    .quad Cond
    .quad ParseDecimal
    .quad ParseHex 
    .quad ParseWord
WordEnd LiteralCheck

Code IsEndReached
    leaq InputBuffer(%rip), %r9 
    cmpq %r8, %r9
    je Reached
        decq %r8
        movq $(0x1), %rax
        jmp ReachedDone
    Reached:    
        movq $(0x0), %rax
    ReachedDone:
        PushDataStack %rax
CodeEnd IsEndReached

Word ExecuteSession
    # %r8 as Buffer Start Register, which holds the starting position
    # where lexer starts (which actually is the end of buffer). While
    # %r9 the Buffer End register, which sometimes holds the position
    # where the word starts, sometimes holds the length of the word
    
    .quad LocateWordBound
    .quad MatchNumber
    .quad LiteralCheck 
    .quad IsEndReached
    .quad LoopWhileNot

WordEnd ExecuteSession

Word InitScan
    .quad InitLocateWord
    .quad ExecuteSession
WordEnd InitScan
