
# Different types of matching functions, used by
# entry matching. There could be several types of
# entry, which matches exact name string, or a
# pattern of characters. 

.macro EntryMatch name, EntryReg, Type
    
    EntryCheck\name:
	
        leaq Entry\name(%rip), \EntryReg
        call \Type

	leaq EntryBegin\name(%rip), \EntryReg
	jmp  MatchDone

.endm

.macro EntryExactMatch name, EntryReg
    EntryMatch \name, \EntryReg, MatchExactName
.endm

.macro EntryIntegerMatch EntryReg
    IntegerCheck:

        call MatchInteger

        leaq IntegerHandlerBegin(%rip), \EntryReg
        jmp  MatchDone

.endm


