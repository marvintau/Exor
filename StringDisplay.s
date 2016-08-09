
# OUTPUT STRING CONSTANT
# ======================
# A handful macro that defines a code word that output a string. Useful
# in debugging stage, but considered to be removed in future release,
# since a general word that output given string address will be more 
# efficient, and takes less space.

# Before we developed the word that enables us to define string in run
# time, we will keep using this one.

.macro StringConst name, string
    Code \name

        jmp SkippedContent\name
            String Content\name, "\string"
        SkippedContent\name:
            push %r15
            leaq Content\name(%rip), %r15
            leaq -8(%r15), %r15
            call PrintConstString
            pop  %r15       

            ExecuteNextWord %r12
     
    CodeEnd \name

.endm

StringConst Jesus, "BELOVED SON\n"
StringConst Maria, "THE VIRGIN\n"
