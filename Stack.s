.macro InitStack StackReg
	leaq Stack(%rip), \StackReg
.endm

.macro PushStack DataReg, StackReg
	movq \DataReg, \StackReg
	leaq  8(\StackReg), \StackReg
.endm

.macro PopStack StackReg, Action
	\Action \StackRag
	leaq  -8(\StackReg), \StackReg
.endm

.macro PopStackPrint StackReg
	PopStack \StackReg, PrintDef
.endm