
# =========================================================================
# MATCH NAME 
# =========================================================================
# Compare the user input stored in buffer, located by %r8 the address and
# %r9 the length, against the entry name from %r11

Code MatchName_Branch
    
    xorq %rax, %rax
    
    # -------------COMPARE LENGTH----------------
    
    movq %r9, %rcx
    cmpq (%r11), %rcx
    jne MatchExactNameDone 

    # ---------COMPARE EACH CHARACTER------------
    
    ForEachCharacter:		
        movb  -1(%r8, %rcx), %al
        cmpb  7(%r11, %rcx), %al
        jne MatchExactNameDone 
    loop ForEachCharacter

    # ---------DECIDE WHETER TO EVAL-------------

    MatchExactNameDone:
        setne %al
        BranchStep %rax
 
CodeEnd MatchName_Branch

# ======================================================
# EVAL
# ======================================================

# Save the current runtime context and go to the routine
# defined by user words. No registers are preserved, but
# guaranteed to lead the instruction pointer back.

Code Eval_Branch
    
    # For debugging
    incq EvaluationLevel(%rip)

    # Save context and prepare to jump to the new
    # session
    movq %r11, %r12
    GoToDefinition %r12
    PushStack %r13
    leaq ReturnAddress(%rip), %r13
    
    jmp *(%r12)

    # -------------LEFT CURRENT SESSION-----------------

    EvaluateDone:
        decq EvaluationLevel(%rip)
        PopStack %r13

    # 4 for the distance to DefineLiteral 
    movq $(3), %rax
    # leave this to Cond
    BranchStep %rax

CodeEnd Eval_Branch

# ======================================================
# RETURN
# ======================================================

# A word that merely referred by Eval, that guide the
# instruction pointer back to the code starting from
# EvaluateDone in Eval.
Code Return 
    jmp EvaluateDone 
ReturnAddress:
    .quad Return
CodeEnd Return

Code NextEntry
    GoToNextEntry %r11
CodeEnd NextEntry

Code EndNotReached_LoopWhile

    cmpq $(0x0), (%r11)
    je EndReached
    ReEnterWord

EndReached:
CodeEnd EndNotReached_LoopWhile

Word FindIteration
    .quad MatchName_Branch
    .quad Eval_Branch
    .quad NextEntry
    .quad EndNotReached_LoopWhile 
    .quad DefineLiteral
WordEnd FindIteration

Code EnterEntry
    movq DictionaryStartAddress(%rip), %r11 
    GoToNextEntry %r11
CodeEnd EnterEntry

Word ParseWord
    .quad EnterEntry
    .quad FindIteration
WordEnd ParseWord

Code PrintEntryName
    jmp PrintCode
NewlineString:
    .asciz "\n"
PrintCode:

    pushq   %rsi
    pushq   %rdx
    pushq   %r11

    movq    $SyscallDisplay, %rax
    movq    $1, %rdi
    movq    $1, %rbx
    leaq    8(%r11), %rsi
    movq    (%r11), %rdx
    syscall
	
    movq    $SyscallDisplay, %rax
    movq    $1, %rdi
    movq    $1, %rbx
    leaq    NewlineString(%rip), %rsi
    movq    $1, %rdx
    syscall

    popq    %r11
    popq    %rdx
    popq    %rsi


CodeEnd PrintEntryName

Word PrintEntryNameIteration
    .quad PrintEntryName
    .quad NextEntry
    .quad EndNotReached_LoopWhile
WordEnd PrintEntryNameIteration

Word PrintEntryNames
    .quad EnterEntry
    .quad PrintEntryNameIteration
WordEnd PrintEntryNames

