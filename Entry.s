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


_main:
	
	ScanInputBuffer
	ParseInputBuffer
	EvaluateUserLexusWith FindEntry

	ExitProgram	

.section __DATA, __data
.include "DataSegment.s"
