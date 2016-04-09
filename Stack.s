// A principle: if a register is guaranteed to be defined
// (modified) before used, then no need to push and pop it.

.macro PrintEntry Reg
	addq $0x8, \Reg
	Print \Reg, -8(\Reg)
	subq $0x8, \Reg
.endm

.macro PrintDef Reg
	MoveToDef \Reg
	addq $0x9, \Reg
	Print \Reg, -8(\Reg)
	subq $0x9, \Reg
.endm


// For stack operations, only two registers are used in each
// macro functions. %r15 stores the stack address, while %r14
// are for storing the popped data, which is only appear in
// pop-related macro functions.

.macro InitStack
	push %r15
	leaq Stack(%rip), %r15
	movq %r15, StackPointer(%rip) 
	pop  %r15
.endm

.macro PushStack DataReg
	push %r15
	movq StackPointer(%rip), %r15
	movq \DataReg, (%r15)
	leaq  8(%r15), %r15
	movq %r15, StackPointer(%rip)
	pop  %r15
.endm

.macro PopStack Action
	push %r15
	push %r14
	movq StackPointer(%rip), %r15
	leaq -8(%r15), %r15
	movq (%r15), %r14
	// Execute %r14, \Action
	call Execute
	movq %r15, StackPointer(%rip)
	pop  %r14
	pop  %r15
.endm

.macro DepleteStack Action
	push %r15
	push %r14
	leaq Stack(%rip), %r15
	DepleteStack_ForEachElem:
		PopStack \Action
		movq StackPointer(%rip), %r14
		cmpq %r15, %r14
	jne DepleteStack_ForEachElem

	pop  %r14
	pop  %r15
.endm

// The word defined by other words introduces a recursive
// manner of parsing the words. The %r13 will be modified,
// but since %r13 is guaranteed to be defined before used,
// (so as %rcx), considering move them out of the macro
// or functions to save the stack.

// Thus, Reg (%r14) will be pushed onto stack and pop back
// after the recursive parse is done.

.macro TraverseDefinition Reg, Action

	movq (\Reg), %r13
	leaq 9(\Reg, %r13), \Reg
	// now %r13 can be safely modified.

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

TraverseDefinition:
	TraverseDefinition %r14, PrintDef
	ret


.macro Execute Reg, Action
	
	movq (\Reg), %r13
	cmpb $(0x00), 8(\Reg, %r13)
	// Now %r13 is no more useful

	je StringConfirmed
	jne WordSeqConfirmed

	StringConfirmed:
		\Action \Reg
		jmp ConfirmedDone
	WordSeqConfirmed:
		// TraverseDef \Reg, \Action
		call TraverseDefinition
	ConfirmedDone:

.endm

Execute:
	Execute %r14, PrintDef
	ret