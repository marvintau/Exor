.macro String name, content
	Length\name:
		.quad(End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

.macro EntryHeader name

    Header\name:
        String Entry\name, "\name"

    \name:
.endm

.macro EntryEnd name

    EntryEndOf\name:
	.quad (Header\name - DictEnd)

.endm

.macro StringDisplay name, string
    EntryHeader \name
    
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

.macro EntryWordSequence name
    EntryHeader \name
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
