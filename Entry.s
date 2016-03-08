/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __DATA, __data
.include "DataSegment.s"
.include "ExorMacros.s"

string1:
	.asciz "haha"
string2:
	.asciz "haha"
stringLength:
	.quad  4

.section __TEXT, __text
.include "IO.s"


.globl _main

FindEntry:

_main:

	// cld

	// pushq	%rbp
	// movq	%rsp, %rbp

	
	// ScanStringBuffer
	// ParseStringBuffer
	// EvaluateUserLexusWith DisplayUserLexus
	// popq	%rbp

	CompareString string1, string2, stringLength
	je Equal
	DisplayStringConstant haha, "Not Equal"
	
	Equal:
		DisplayStringConstant hehe, "Equal"

	ExitProgram	
