
.macro ExecuteWholeStack
    ExecuteNextElem:
	PopStack 
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

ExecuteWord:
    ExecuteWord %r14
    ret


.macro Execute Reg

    jmpq *(\Reg)
    ExecuteDone:

.endm


Execute:
    Execute %r14
    ret
