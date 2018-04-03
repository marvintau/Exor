
# For stack operations, only two registers are used in each
# macro functions. %r10 stores the stack address, while %r14
# are for storing the popped data, which is only appear in
# pop-related macro functions.

.macro InitStack
    leaq Stack(%rip), %r10
.endm

.macro PushStack Reg
    movq \Reg, (%r10)
    leaq  8(%r10), %r10
.endm

.macro PopStack Reg
    leaq -8(%r10), %r10
    movq (%r10), \Reg
.endm



# EXECUTE
# ====================
# The term "Execute" can be understood as modifying the
# order of reading and performing the instructions. But
# differing to control flow, the instructions that being
# executed is subsidiary to some other instructions.

# In order to control the execution, we only need two
# registers. One holds the address to be jumped and the
# other the address to be jumped out to.

# Since we have the words that refer to other words, rather
# than merely containing code, we need to use indirected
# addressing. Instead of jumping to the address stored
# in register, the program jumps to the address, that
# stored in some other certain address, which stored in
# that register. Like second-order jump.

# This second-order jump means that the content in the
# register, must POINT to some address which is the start
# of executable instructions. This basically formed the
# structure of the entries.

EntryHeader BacktracingPrint
    jmp BacktracingPrintStart

Arrow:
    .ascii " ==> "
NewLine:
    .ascii "\n"

BacktracingPrintStart:

    pushq   %rax
    pushq   %rbx
    pushq   %rcx
    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %r11

    movq    EvaluationLevel(%rip), %rax
    cmpq     $(0), %rax
    je      BacktracingPrintContinue

    # %r12 currently points to the address where actual
    # code or the code of enterword begins. The following
    # two steps makes %rax points to the entry header.

    pushq  %rax
    movq   $SyscallDisplay, %rax
    movq   $(1), %rdi
    movq   $(1), %rbx
    leaq   Arrow(%rip), %rsi
    movq   $(5), %rdx
    syscall

    popq    %rax
    movq    %r12, %rax              
    subq    -8(%rax), %rax          
                                   
    movq    (%rax), %rdx           
    leaq    8(%rax), %rsi

    movq    $SyscallDisplay, %rax
    movq    $(1), %rdi
    movq    $(1), %rbx
    syscall

    movq   $SyscallDisplay, %rax
    movq   $(1), %rdi
    movq   $(1), %rbx
    leaq   NewLine(%rip), %rsi
    movq   $(1), %rdx
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
EntryEnd BacktracingPrint 

EntryHeader ExecuteNextWord
    call BacktracingPrint
    movq  (%r13), %r12
    leaq 8(%r13), %r13
    jmpq *(%r12)
EntryEnd ExecuteNextWord

# ENTERWORD
# =====================
# EnterWord is a subroutine that essentially does two things
# First it stores the original Return Address Register (RAR),
# which similar to the frame register that stores the caller
# address in function call. Secondly it leads the instruction
# pointer points to the referred entry by changing the Entry
# Register (ER).


EntryHeader EnterWord
    PushStack %r13
    leaq 8(%r12),  %r12
    movq   %r12,   %r13
    jmp ExecuteNextWord
EntryEnd EnterWord

EntryHeader SystemEntrance
ExitAddress:
    .quad SystemExit

ExecuteSystemWord:
    InitStack

    leaq ExitAddress(%rip), %r13

    leaq InitScan(%rip), %r11 
    movq %r11, %r12
    jmp  *(%r12)
EntryEnd SystemEntrance


