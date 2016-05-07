# A principle: if a register is guaranteed to be defined
# (modified) before used, then no need to push and pop it.

.macro PrintEntry Reg
    addq $0x8, \Reg
    Print \Reg, -8(\Reg)
    subq $0x8, \Reg
.endm


# For stack operations, only two registers are used in each
# macro functions. %r15 stores the stack address, while %r14
# are for storing the popped data, which is only appear in
# pop-related macro functions.

.macro InitStack
    leaq Stack(%rip), %r15
    movq %r15, StackPointer(%rip) 
.endm

.macro PushStack DataReg
    movq StackPointer(%rip), %r15
    movq \DataReg, (%r15)
    leaq  8(%r15), %r15
    movq %r15, StackPointer(%rip)
.endm

.macro PopStack
    push %r15
    push %r14

    movq StackPointer(%rip), %r15
    leaq Stack(%rip), %r14
    cmpq %r14, %r15
    je   StackBaseReached    

    leaq -8(%r15), %r15
    movq (%r15), %r14
    call Execute

    StackBaseReached:
    movq %r15, StackPointer(%rip)
    pop  %r14
    pop  %r15
.endm

.macro ExecuteWholeStack
    ExecuteStackNextElem:
	PopStack 
        jne ExecuteStackNextElem
.endm

.macro ExecuteWordSubRoutine Reg


	movq (\Reg), %rcx
	ForEachWordInEntry:
		push \Reg
		push %rcx

		movq (\Reg, %rcx, 8), \Reg
		call Execute

		pop  %rcx
		pop \Reg
	loop ForEachWordInEntry

.endm

ExecuteWordSubRoutine:
	ExecuteWordSubRoutine %r14
	ret


.macro Execute Reg
	
	# SANITY CHECK:
	# Now the reg is pointing to the EntryBegin\name
	# First to check if it's a compound word or code.
	# No matter it's a word or code, we make the reg
	# point to actual content.
        leaq 8(\Reg), \Reg
	ExecuteCode:
		jmpq *\Reg
		jmp ExecuteDone
	ExecuteDone:

.endm

Execute:
	Execute %r14
	ret
