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


