# this micro-benchmark should work with the label file `eliminate-label.txt`

.macro sec.or   rd, rs1, rs2 
 or   \rd, \rs1, \rs2 
.endm

.org 0x80
nop
sec.or   x5,  x5, x0
and      x6,  x6, x6
sec.or   x12, x5, x0  # overwrite a share with another share to check if there's now an architecutral leakage
nop
nop
nop
nop
nop
nop
nop
nop
nop
