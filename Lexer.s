
# Used by ScanInputBuffer
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

# Notably, since we have pushed string address register
# and length register here, it's safe to use them for
# different purpose in called Action subroutine. By
# convention, the two registers are %r8 and %r9
.macro Prepare StrAddrReg, LengthReg, For, Action

    subq \LengthReg, \StrAddrReg

    call \Action

    addq \LengthReg, \StrAddrReg
        
.endm

.macro CheckCharEdgeWith StrAddrReg, LengthReg, Action
        cmpb $(0x20), (\StrAddrReg)
        je   StartWithSpace
        jne  StartWithChar
    
    StartWithSpace:
        cmpb $(0x20), 1(\StrAddrReg)
        je   Done

        ButNextIsChar:
            movq $(0x0), \LengthReg
            jmp Done

    StartWithChar:
        cmpb $(0x20), 1(\StrAddrReg)
        je   ButNextIsSpace

        StillChar:
            incq \LengthReg
            jmp  Done

        ButNextIsSpace:
            Prepare \StrAddrReg, \LengthReg, For, \Action
    Done:
        incq \StrAddrReg
.endm

.macro InitParse
    # Assign the input buffer and length to proper registers.
    # AND NEVER CHANGE LATER! NO MORE PUSH AND POP!
.endm

.macro LocateWord
.endm

.macro LexWholeSequence 


    leaq InputBuffer(%rip), %r9
    xorq %r8, %r8
    movq InputBufferLength(%rip), %rcx

    # Handles zero lengthed user input
    test %rcx, %rcx
    je   Apply_ForEachWord_Done
    
    Apply_ForEachWord:
        CheckCharEdgeWith %r9, %r8, Find
        loop Apply_ForEachWord
    Apply_ForEachWord_Done:


.endm
