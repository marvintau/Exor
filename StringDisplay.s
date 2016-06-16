.macro StringDisplay name, string
    Code Sub\name

        jmp SkippedContent\name
            String Content\name, "\string"
        SkippedContent\name:
            push %r15
            leaq Content\name(%rip), %r15
	    Print %r15, -8(%r15)
            pop  %r15       

            ExecuteNextWord %r12
     
    CodeEnd Sub\name

    Word \name
        .quad Sub\name
    LoopEnd \name
.endm

StringDisplay Jesus, "BELOVED SON\n"

Word JesusWord
    .quad Jesus 
WordEnd JesusWord


