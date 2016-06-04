# Lexer uses r8 and r9 register

.macro ScanInputBuffer
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

.endm

.macro InitLocateWord StartReg, EndReg 

    # setting up the StartReg, and make it point to the
    # last input character in the buffer.
    
    leaq InputBuffer(%rip), \StartReg
    addq InputBufferLength(%rip), \StartReg

.endm

# Always terminates when a bigram of char followed with
# a space is found, with StartReg pointing to initial,
# and EndReg to first space after last char. 

.macro LocateNextWord StartReg, EndReg 

    leaq InputBuffer(%rip), %rax 

    NextBigram:
        cmpq \StartReg, %rax 
        je   WordLocated

        cmpb $(0x20), (\StartReg)
        je   StartWithSpace
        jne  StartWithChar

        StartWithSpace:
            xorq \EndReg, \EndReg
            cmpb $(0x20), -1(\StartReg)
            je  MoveCurr 

            CharNext:
                movq \StartReg, \EndReg
                jmp MoveCurr 

        StartWithChar:
            cmpb $(0x20), -1(\StartReg) 
            jne MoveCurr 

            SpaceNext:

                jmp WordLocated

        MoveCurr:

            decq \StartReg
        
        jmp NextBigram 

    WordLocated:

        #push \StartReg
        #push \EndReg

.endm

.macro AreWeDone StartReg, EndReg, LoopLabel, DoneLabel

    leaq InputBuffer(%rip), \EndReg
    cmpq \StartReg, \EndReg
    je   \DoneLabel
    
    decq \StartReg
    jmp  \LoopLabel

.endm

.macro ExecuteAllWords StartReg, EndReg, Action

    InitLocateWord \StartReg, \EndReg

    NextWord:
        LocateNextWord \StartReg, \EndReg
        subq \StartReg, \EndReg
        call \Action 
        AreWeDone \StartReg, \EndReg, NextWord, AllDone 
    AllDone:        
        
.endm


