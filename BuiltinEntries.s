
# BRANCHING
# =========
# jump to word entrance with rax as offset. Notably that
# the branching can be only used in a word, and has to be
# placed in the beginning of the word. Since we have no
# flow control statement like break and continue, we just
# implement the branching block as a new function, and 
# return to caller after finishing executing the subroutine.

Code Branch
    PopDataStack %rax

    leaq (%r13, %rax, 8), %r13
CodeEnd Branch

# EXIT WORD
# ===================
# Restores the address of caller word
Code Exit
    PopStack %r13
CodeEnd Exit

Code LoopExit
    PopStack %r13
Beef:
    subq $(0x8), %r13
CodeEnd LoopExit

# QUIT WORD
# ===================
# Brutally quit the current evaluation session
Code Quit
    .quad RealQuit
RealQuit:
    jmp ExecutionDone
CodeEnd Quit

Code SystemExit 
    .quad RealSystemExit 
RealSystemExit:
    jmp SystemExitLabel 
CodeEnd SystemExit
