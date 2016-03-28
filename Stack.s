.macro InitStack StackReg
	leaq Stack(%rip), \StackReg
.endm

.macro PushStack DataReg, StackReg
	movq \DataReg, \StackReg
	leaq  8(\StackReg), \StackReg
.endm

.macro PopStack StackRag, Action
	\Action \StackRag
	leaq  -8(\StackReg), \StackReg
.endm

.macro FindEntryThroughStack