
# BRANCHING
# =========
# jump to word entrance with rax as offset. Notably that
# the branching can be only used in a word, and has to be
# placed in the beginning of the word. Since we have no
# flow control statement like break and continue, we just
# implement the branching block as a new function, and 
# return to caller after finishing executing the subroutine.

Code Cond 
    PopDataStack %rax
    leaq (%r13, %rax, 8), %r13
CodeEnd Cond 

Code LoopWhileNot
    # Consumes an element on Data Stack
    PopDataStack %rax
CheckRax2:
    cmp $(0x0), %rax
    je SkipLoop    

    PopStack %r13
    subq $(0x8), %r13
SkipLoop:
CodeEnd LoopWhileNot

Code LoopLikeForever
    PopStack %r13
    subq $(0x8), %r13
CodeEnd LoopLikeForever

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
    .quad RealSystemExit 
RealSystemExit:
    jmp SystemExitLabel 
CodeEnd SystemExit
