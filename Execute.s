
# EXECUTE
# ====================
# This part mainly manipulates the entering and exiting
# words that consist of either executable code or other
# words. This could be the most interesting and tricky
# part in the whole project. Have fun in reading!


# EXECUTE NEXT WORD
# ===================
# %r12 stores the address pointing to a quad that points
# to another word. So we may jump into that code through
# indirect jumping. And the destination should be always
# an executable instruction.

# If we just have the %r12 stores the address that about
# jump to, then there is no need to use indirect jumping,
# (the parentheses). If we are going to use it, %r12 has
# to POINT TO ANOTHER ADDRESS TO JUMP TO. (Ponder it!)

# And you are right. %r12 is never pointing to an address
# that you can jump to and execute, but a quad pointing
# to another piece of code. If the entry has executable 
# code, then this quad should be the starting address of
# the code. If the entry is a word that contains other
# words, then this should be EnterWord.

.macro ExecuteNextWord
    movq  (%r13), %r12
    leaq 8(%r13), %r13 
    jmpq *(%r12)

.endm

# ENTERWORD
# =====================
# EnterWord is a subroutine that essentially does two things
# First it stores the original Return Address Register (RAR),
# which similar to the frame register that stores the caller
# address in function call. Secondly it leads the instruction
# pointer points to the referred entry by changing the Entry
# Register (ER).

EnterWord:
    PushStack %r13
    leaq 8(%r12),  %r12
    movq   %r12,   %r13
    ExecuteNextWord

# ENTER FIRST WORD
# ======================
# Since there is no prior word entry referring, we just stores
# the address of exiting routine in the RAR, instead of pushing
# another address into it.

ExecuteLexedWord:
    PushStack %r13
    leaq ReturnLexer(%rip), %r13

    movq %r11, %r12
    jmp *(%r12)


ExecuteSystemWord:
    leaq SystemExit(%rip), %r13
    
    movq %r11, %r12
    jmp  *(%r12)


