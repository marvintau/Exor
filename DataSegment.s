
# Used by ParseStringBuffer
# The length should always be the half of StringBuffer
UserLexusOffset:
	.quad	0
UserLexusLength:
	.quad	0
UserLexus:
	.fill	128, 1, 0x00
UserLexusEnd:

# Used by ScanStringBuffer
StringBufferLength:
	.quad	0
StringBuffer:
	.fill 	256, 1, 0x00 
StringBufferEnd:
