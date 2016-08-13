
# EXECUTE
# ====================
# This part mainly manipulates the entering and exiting
# of words that include either executable code or other
# words.  This could be the most interesting and tricky
# part in the whole project. Have fun in reading!

# The problem here is that, there are two kinds of word
# which one kind stores executable code, while the other
# stores a series of address that points to other words,
# which is not able to execute. Before jumping into the
# referred word, we are not able to distinguish whether
# a word consists of code or other word address.

# The Indirect Addressing is an elegant solution to this
# issue. This avoids us to write complex handler and the
# code header. Indirect addressing essentially leads the
# instruction pointer to a place, where the address is
# stored somewhere, that referred by another address that
# stored in the register. (Ponder this!)

# Therefore, the word that contains executable code, has
# a quad holds the actual starting point of executable
# code, yet the word referring to other words, also has
# a quad holds a common subroutine, that push the referer
# onto stack, take the current word as new referer, and
# go into the following referred words.

# Without indirect addressing, we will have to implement
# the code that jump back to referer word in every word, 
# and it will be hard to separate the word address away
# from assembly code. Indirect addressing just need one
# more quad to store the starting address of actual code
# in word containing code, and one more quad for word
# containing other words to jump into the referred word.


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


BacktracingPrint:

    jmp BacktracingPrintStart

Arrow:
    .ascii " ==> "

BacktracingPrintStart:

    pushq   %rax
    pushq   %rbx
    pushq   %rcx
    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %r11

    # %r12 currently points to the address where actual
    # code or the code of enterword begins. The following
    # two steps makes %rax points to the entry header.
    movq    %r12, %rax              
    subq    -8(%rax), %rax          

    #cmp     $(0), %rax
    #je      BacktracingPrintContinue
                                    
    movq    (%rax), %rdx           
    leaq    8(%rax), %rsi

    movq    $SyscallDisplay, %rax
    movq    $(1), %rdi
    movq    $(1), %rbx
    syscall
    
    movq   $SyscallDisplay, %rax
    movq   $(1), %rdi
    movq   $(1), %rbx
    leaq   Arrow(%rip), %rsi
    movq   $(5), %rdx
    syscall

BacktracingPrintContinue:
 
    popq    %r11
    popq    %rdx
    popq    %rsi
    popq    %rdi
    popq    %rcx
    popq    %rbx
    popq    %rax
    ret

ExecuteNextWord:
    movq  (%r13), %r12
    call BacktracingPrint
    leaq 8(%r13), %r13

 
    jmpq *(%r12)

.macro ExecuteNextWord
    jmp ExecuteNextWord
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

ExitAddress:
    .quad SystemExit

ExecuteSystemWord:
    leaq ExitAddress(%rip), %r13
    
    movq %r11, %r12
    jmp  *(%r12)


