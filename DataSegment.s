
// UserLexus is a region that stores the
// offset of each word in the string buffer
UserLexusOffset:
	.quad	0
UserLexusLength:
	.quad	0
UserLexus:
	.fill	128, 1, 0x00
UserLexusEnd:

// Used by ScanInputBuffer
InputBufferLength:
	.quad	0
InputBuffer:
	.fill 	256, 1, 0x00 
InputBufferEnd:

DummyWords:
	DefineDummyWord God, "He Is Who He Is\n"
	DefineDummyWord Adam, "First created man\n"
	DefineDummyWord Eve, "First created woman"
	.word 0xbeef 
DummyWordsEnd:
