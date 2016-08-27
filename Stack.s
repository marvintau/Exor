# A principle: if a register is guaranteed to be defined
# (modified) before used, then no need to push and pop it.

.macro PrintEntry Reg
    addq $0x8, \Reg
    Print \Reg, -8(\Reg)
    subq $0x8, \Reg
.endm


# For stack operations, only two registers are used in each
# macro functions. %r10 stores the stack address, while %r14
# are for storing the popped data, which is only appear in
# pop-related macro functions.

.macro InitStack
    leaq Stack(%rip), %r10
.endm

.macro PushStack Reg
    movq \Reg, (%r10)
    leaq  8(%r10), %r10
.endm

.macro PopStack Reg
    leaq -8(%r10), %r10
    movq (%r10), \Reg
.endm
