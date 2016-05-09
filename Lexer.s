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
    incq \LengthReg

    movq \StrAddrReg, WordOffset(%rip)
    movq \LengthReg, WordLength(%rip)
    call \Action

    decq \LengthReg
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

.macro Parse
    push %r9
    push %r8

    leaq InputBuffer(%rip), %r9
    movq InputBufferLength(%rip), %rcx

    # Handles zero lengthed user input
    test %rcx, %rcx
    je   Apply_ForEachWord_Done
    
    Apply_ForEachWord:
        push %rcx
        CheckCharEdgeWith %r9, %r8, Find
        popq %rcx
        loop Apply_ForEachWord
    Apply_ForEachWord_Done:

    pop %r8
    pop %r9
.endm
