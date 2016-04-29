// A principle: if a register is guaranteed to be defined
// (modified) before used, then no need to push and pop it.

.macro PrintEntry Reg
	addq $0x8, \Reg
	Print \Reg, -8(\Reg)
	subq $0x8, \Reg
.endm


// For stack operations, only two registers are used in each
// macro functions. %r15 stores the stack address, while %r14
// are for storing the popped data, which is only appear in
// pop-related macro functions.

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
	leaq -8(%r15), %r15
	movq (%r15), %r14
	call Execute

	movq %r15, StackPointer(%rip)
	pop  %r14
	pop  %r15
.endm

.macro ExecuteStack
	leaq Stack(%rip), %r15

	//Check emptiness
	movq StackPointer(%rip), %r14
	cmpq %r15, %r14
	je ExecuteStack_ForEachElem_Done

	ExecuteStack_ForEachElem:
		PopStack \Action
		movq StackPointer(%rip), %r14
		cmpq %r15, %r14
		jne ExecuteStack_ForEachElem

	ExecuteStack_ForEachElem_Done:
.endm

.macro ExecuteWordSubRoutine Reg, Action

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

ExecuteWordSubRoutine:
	ExecuteWordSubRoutine %r14, PrintDef
	ret


.macro Execute Reg
	
	// Sanity check:
	// the \Reg still holds the address of initial byte
	// of the length quad.
	movq (\Reg), %r13
	cmpb $(0x00), 8(\Reg, %r13)

	je ExecuteCode
	jne ExecuteWord

	ExecuteCode:
		MoveToDef \Reg
		AfterMoveToDef:
		// When we are about to jump to the code in the
		// definition, first we need to move the reg to
		// the starting byte of code, located at X of:
		// V(\Reg)
		// |8:Len|Len:Name|1:type|X.....
		jmpq *\Reg
		jmp ExecuteDone
	ExecuteWord:
		// TraverseDef \Reg, \Action
		call ExecuteWordSubRoutine
	ExecuteDone:

.endm

Execute:
	Execute %r14
	ret