# Initialize LocateWord
# =====================
# r8 always stores the starting of Input buffer, yet
# r9 always stores the length of the buffer.

Code InitLocateWord
    leaq InputBuffer(%rip), %r8
    addq InputBufferLength(%rip), %r8
CodeEnd InitLocateWord

Code ScanInputBuffer
    movq    $SyscallRead, %rax
    movl    $(1), %edi
    leaq    InputBuffer(%rip), %rsi
    movq    $(InputBufferEnd - InputBuffer), %rdx
    syscall

    # replace the final enter (carriage return)
    # as a white space, for falling edge check
    # when parsing
    decq    %rax
    movq    $(0x20), (%rsi, %rax)

    # Store buffer length
    movq    %rax, InputBufferLength(%rip)
CodeEnd ScanInputBuffer

Code ExecuteSession
    # %r8 as Buffer Start Register, which holds the starting position
    # where lexer starts (which actually is the end of buffer). While
    # %r9 the Buffer End register, which sometimes holds the position
    # where the word starts, sometimes holds the length of the word
    
    NextWord:
        LocateNextWord %r8, %r9
        subq %r8, %r9
        
        MatchNumber %r8, %r9
        cmpb $1, %ah

    NumberCheck:
        jg RecognizedAsWord
            je RecognizedAsHex
                ParseDecimal %r8, %r9 
                jmp FirstMatchDone

            RecognizedAsHex:
                ParseHex %r8, %r9
                jmp FirstMatchDone

        RecognizedAsWord:
            call Find 
        
        FirstMatchDone:

        AreWeDone %r8, %r9, NextWord, AllDone 
    AllDone:        
 CodeEnd ExecuteSession

Word InitScan
    .quad InitLocateWord
#    .quad ScanInputBuffer
    .quad ExecuteSession
WordEnd InitScan
