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
	\Action %r14
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