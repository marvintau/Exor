
# =========================================================================
# MATCH NAME 
# =========================================================================
# Compare the user input stored in buffer, located by %r8 the address and
# %r9 the length, against the entry name from %r11

Code MatchName
    
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

    # ---------DECIDE WHETHER TO EVAL-------------

    MatchExactNameDone:
        setne %al

    # ------- CHECK IF WE ARE COMPILING ----------

        cmp $(0x0), %r14
        je CheckCompilingDone
        shlq $(0x1), %rax

    CheckCompilingDone:

        BranchStep %rax
 
CodeEnd MatchName

# ========================================================================
# EVAL
# ========================================================================

# Save the current runtime context and go to the word from user console.
# No registers are preserved, except r13. However, if we are in compiling
# mode, then it simply push the entry address onto the parameter stack.

# The eval implemented here is more like a generalized service. Different
# functionalities are integrated here for consideration of performance and
# simplicity. The Eval for user word in the future will be only part of it.


.macro EvaluateCore EntryPointerRegister

    # ------------- ENABLING DEBUGGING ----------------- 

    incq EvaluationLevel(%rip)

    # ------------- PREPARE FOR WARPING ---------------- 
    movq \EntryPointerRegister, %r12
    GoToDefinition %r12
    PushStack %r13
    leaq ReturnAddress(%rip), %r13
    
    jmp *(%r12)

    # ------------ LEFT CURRENT SESSION ----------------

    EvaluateDone:
        decq EvaluationLevel(%rip)
        PopStack %r13

.endm

.macro Compile

    pushq %r11
    addq $(0x1), %r14

.endm

Code Eval

    # ------------- CHECK IF COMPILING -----------------

    cmpq $(0x0), %r14
    je Evaluate

    # ------------- PUSH ENTRY ADDRESS -----------------

    Compile

Evaluate:

    EvaluateCore %r11 

AllDone:
    # 3 for the distance to DefineLiteral 
    movq $(3), %rax

    # leave this to Cond
    BranchStep %rax

CodeEnd Eval

# ========================================================================
# RETURN
# ========================================================================

# A word that merely referred by Eval, that guides the instruction pointer
# back to the code starting from EvaluateDone in Eval.

Code Return 
    jmp EvaluateDone 
ReturnAddress:
    .quad Return
CodeEnd Return

# ========================================================================
# AS
# ========================================================================

# A word used with other word for compiling. It almost does nothing except
# setting 1 to r14, which will be a mark to notice the matcher that we are
# currently running in compiling mode.

Code As
    movq $(0x1), %r14
CodeEnd As

# ========================================================================
# DEFINE 
# ========================================================================

# Restore the pushed address and write them to the new word location

Code Define 

    # ------------------- REWINDING ---------------------------
    # First we go back to the position where the content of the
    # newly added word starts.

    movq DictionaryStartAddress(%rip), %rax
    GoToNextEntry %rax
    GoToDefinition %rax

    # ------------------- EXTRACTING --------------------------
    # Extract the sequence of word address from the parameter
    # stack and write them to proper places.
    
    movq %r14, %rcx

Extract:
    popq %r11
    movq %r11, (%rax, %rcx, 8)
    loop Extract

    # And move the EnterEntry to the first word address position.
    leaq EnterEntry(%rip), %rcx
    movq %rcx, (%rax)

    # ---------------- ADDING ENTRY END ----------------------
 
    # now %rbx is holding the content to be stored on EntryEnd,
    # the distance between DictEnd and DictionaryStartAddress.
    
    movq DictionaryStartAddress(%rip), %rbx
    leaq DictEnd(%rip), %rcx
    subq %rcx, %rbx

    # Now get the new DictionaryStartAddress and store on %rcx,
    # and store the link to proper address.
    
    movq DictionaryStartAddress(%rip), %rcx

    # Get the new DictionaryStartAddress and store into %rcx,
    # an extra 8-byte offset is made for storing the EntryEnd,
    # which used for locating the next entry on dictionary.
    
    leaq 8(%rcx, %r14, 8), %rcx
    movq %rbx, -8(%rcx)

    # Finally, update the new DictionaryStartAddress in
    # memory.
    movq %rcx, DictionaryStartAddress(%rip)

CodeEnd Define 

Code NextEntry
    GoToNextEntry %r11
CodeEnd NextEntry

Code LoopWhileEndNotReached 

    cmpq $(0x0), (%r11)
    je EndReached
    ReEnterWord

EndReached:
CodeEnd LoopWhileEndNotReached 

Word InterpretIteration
    .quad MatchName
    .quad Eval
    .quad NextEntry
    .quad LoopWhileEndNotReached 
    .quad DefineLiteral
WordEnd InterpretIteration 

Code EnterEntry
    movq DictionaryStartAddress(%rip), %r11 
    GoToNextEntry %r11
CodeEnd EnterEntry

Word ParseWord
    .quad EnterEntry
    .quad InterpretIteration 
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
    .quad LoopWhileEndNotReached 
WordEnd PrintEntryNameIteration

Word PrintEntryNames
    .quad EnterEntry
    .quad PrintEntryNameIteration
WordEnd PrintEntryNames

