/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __DATA, __data
String1:
	.quad (String1End - .)
	.ascii "Adam"
String1End:

.include "DataSegment.s"
.include "ExorMacros.s"


.section __TEXT, __text
.include "IO.s"


.globl _main

FindEntry:

_main:
	
	leaq String1(%rip), %r12


	addq $(0x8), %r12
	LookUpDummyWords %r12, -8(%r12)
	subq $(0x8), %r12
	ExitProgram	
