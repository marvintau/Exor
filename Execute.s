.macro Execute Reg

    jmpq *(\Reg)
    ExecuteDone:

.endm

.macro ExecuteWholeStack
    ExecuteNextElem:
	PopStack 
        Execute %r15
        jne ExecuteNextElem
.endm

.macro ExecuteWord Reg

    movq (\Reg), %rcx
    movq (%rcx), %rcx
    ForEachWordInEntry:
        push \Reg
        push %rcx

        leaq (\Reg, %rcx, 8), \Reg
        call Execute

        pop  %rcx
        pop \Reg
    loop ForEachWordInEntry

.endm



