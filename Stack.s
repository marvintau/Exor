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
.endm

.macro PushStack DataReg
    movq \DataReg, (%r15)
    leaq  8(%r15), %r15
.endm

.macro PopStack Reg, StackBaseReachedHandler
    
    leaq Stack(%rip), %r14
    cmpq %r14, %r15

    leaq -8(%r15), %r15
    movq (%r15), \Reg


.endm

