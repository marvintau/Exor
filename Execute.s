
.macro ExecuteWholeStack
    ExecuteNextElem:
	PopStack 
        jne ExecuteNextElem
.endm

.macro ExecuteWord Reg

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

ExecuteWord:
    ExecuteWord %r14
    ret


.macro Execute Reg

    jmpq *\Reg
    ExecuteDone:

.endm

.macro Enter EntryReg

    leaq 8(\EntryReg), \EntryReg
    jmpq *\EntryReg

.endm

.macro EnterWord EntryReg
.endm

Execute:
    Execute %r14
    ret
