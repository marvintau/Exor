.macro String name, content
	Length\name:
		.quad(End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

.include "EntryStructureMatching.s"

.macro Entry name, EntryReg

    \name:

    jmp EntryCheck\name
	String Entry\name, "\name"

    EntryExactMatch \name, \EntryReg

    EntryBegin\name:
	.quad (EntryBegin\name - \name)
.endm

.macro EntryEnd name
    EntryEndOf\name:
	.quad (\name - DictEnd)
.endm

.macro Integer EntryReg
    IntegerHandler:
        EntryIntegerMatch \EntryReg
    IntegerHandlerBegin:
        .quad (IntegerHandlerBegin - IntegerHandler)
.endm

.macro StringDisplay name, string
    Entry \name, %r13
	jmp SkippedContent\name
	    String Content\name, "\string"
	SkippedContent\name:
            push %r13
            leaq Content\name(%rip), %r13
            call PrintString
            pop  %r13
            jmp ExecuteDone
	EntryEnd \name
.endm

.macro IntegerDisplay
    Integer %r13
        jmp SkippedInteger
            String Yep, "Integer found\n"
        SkippedInteger:
            push %r13
            leaq Yep(%rip), %r13
            call PrintString
            pop  %r13
            jmp ExecuteDone
        EntryEnd IntegerHandler
.endm

.macro EntryWordSequence name
    Entry \name, %r13
        jmp EndWordSequence\name
    StartOfWordSequence\name:
.endm

.macro EntryWordSequenceEnd name
    EndWordSequence\name:
        push %r14
        leaq StartOfWordSequence\name(%rip), %r14
        call ExecuteWord 
        pop  %r14
        jmp  ExecuteDone
    EntryEnd \name
.endm
