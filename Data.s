
.macro String name, content
\name:
	.asciz "\content"
Size\name:
	.quad . - \name
.endm

