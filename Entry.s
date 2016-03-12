/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __TEXT, __text
.include "ExorMacros.s"
.include "IO.s"

.globl _main
PrintWord:
	Print %r13, (%r12)
	ret

FindEntry:
	LookUpEntry %r13, (%r12)
	ret

MainRoutine:
	ScanInputBuffer
	ParseInputBuffer
	EvaluateUserLexusWith FindEntry
	ret	

_main:

MainLoop:
	call MainRoutine
	loop MainLoop

	ExitProgram	

.section __DATA, __data
.include "DataSegment.s"
