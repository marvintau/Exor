
.macro ExecuteNext Reg
    leaq -8(\Reg), \Reg
    jmpq *(\Reg)
.endm

.macro ExitWord Reg
    PopStack \Reg
    jmpq *(\Reg)
.endm
