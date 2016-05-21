
# STRING MACRO
# ======================
# Char array with length

.macro String name, content
	Length\name:
		.quad(End\name - \name)
	\name:
		.ascii "\content"
	End\name:
.endm

# ENTRY HEADER AND END
# ====================
# Defines the entry header label, entry end label
# and the length of whole entry.

.set Type.Code, 0x0000dead
.set Type.Word, 0x0000beef

.macro EntryHeader name, EntryType

    Header\name:
        String Entry\name, "\name"

        .quad \EntryType 
    \name:
.endm

.macro EntryEnd name

    EntryEndOf\name:
	.quad (Header\name - DictEnd)

.endm

.macro StringDisplay name, string
    EntryHeader Sub\name, Type.Code
    
        jmp SkippedContent\name
            String Content\name, "\string"
        SkippedContent\name:
            push %r13
            leaq Content\name(%rip), %r13
            call PrintString
            pop  %r13
       
            ExecuteNextWord %r12
     
    EntryEnd Sub\name

    EntryHeader \name, Type.Word
        .quad EnterWord 
        .quad Sub\name
        .quad ExitWord
    EntryEnd \name
.endm

