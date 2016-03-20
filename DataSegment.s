InputBufferLength:
	.quad	0
InputBuffer:
	.fill 	64, 1, 0x20 
InputBufferEnd:

.macro String name, content
	Length\name:
		.quad(End\name - Start\name)
	Start\name:
		.ascii "\content"
	End\name:
.endm

.macro Entry name, definition
	Entry\name:
	String Entry\name, "\name"
	String Def\name, "\definition"

	EntryEndOf\name:
		.quad (Entry\name - DictEnd)
.endm

DictEnd:
	.quad 0x0000000000000000
	Entry God, "He Is Who He Is\n"
	Entry Jesus, "Beloved Son\n"
	Entry Adam, "First created man\n"
	Entry Eve, "First created woman\n"
DictStart:
/**
 * Due to the limit of address calculation, the beginning
 * quad of an entry, which stores the initial address of
 * the last entry, is actually defined in the last entry.
 * The address that the quad stores, is actually pointing
 * to the first byte of the entry body (the first byte of
 * of the quad that stores the length of the entry name).
 * When trying to access the _NEXT_ entry, you may need to
 * move the address 8 bytes prior in order to get the quad
 * that holds the address.

 * Thus, the starting of the Dictionary can be accessed by
 * leaq DictionaryStart(%rip), %offsetReg
 * leaq DictionaryEnd(%rip), %baseReg
 * movq -8(%baseReg, %offsetReg), %offsetReg
 * 
 * leaq DictionaryEnd(%rip), %baseReg
 * movq -8(%baseReg, %offsetReg), %offsetReg
 *
 * check if the reg is same to the sign of end address before
 * proceeding.
 */