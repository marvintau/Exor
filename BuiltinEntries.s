
# BRANCHING
# =========
# jump to word entrance with rax as offset. Notably that
# the branching can be only used in a word, and has to be
# placed in the beginning of the word. Since we have no
# flow control statement like break and continue, we just
# implement the branching block as a new function, and 
# return to caller after finishing executing the subroutine.

.macro BranchStep StepReg
    leaq (%r13, \StepReg, 8), %r13
    jmp ExecuteNextWord
.endm

Code Cond 
    pop %rax
    BranchStep %rax
CodeEnd Cond 

# CONDITIONAL & UNCONDITIONAL LOOP
# =============
# Takes rax as the number of iteration. rax will be decrease
# time after time, and loop exits if rax reaches 0. The loop
# forever doesn't take any number, it's just like jump back
# to the beginning of the current word.

.macro ReEnterWord
    PopStack %r13
    subq $(0x8), %r13
    jmp ExecuteNextWord
.endm

Code LoopWhile
    pop %rax
    cmp $(0x0), %rax
    je SkipLoop    

    ReEnterWord

SkipLoop:
CodeEnd LoopWhile

Code LoopUncond
    ReEnterWord
CodeEnd LoopUncond

# EXIT WORD
# ===================
# Restores the address of caller word
Code Exit
    PopStack %r13
CodeEnd Exit

# QUIT WORD
# ===================
# Brutally quit the current evaluation session
Code SystemExit 
    jmp SystemExitLabel 
CodeEnd SystemExit


