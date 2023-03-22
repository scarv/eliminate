# this micro-benchmark should work with the label file `eliminate-label.txt`

# the following commented case (i.e., using normal `sw`) doesn't pass the test
# sw       x5,  0(x13)
# and      x6, x6, x6
# sw      x12,  0(x13)

# now to test the case using secure store (i.e., `sec.sw`)

.macro sec.sw   rs2, rs1, imm
.insn s CUSTOM_1, 1, \rs2, \imm(\rs1)
.endm 

.org 0x80
nop
li       x13, 0x20
sec.sw   x5,  x13, 0
and      x6,  x6, x6
# overwrite a share with another share to check if there's now 
# an architecutral leakage and/or a micro-architectural leakage
sec.sw   x12, x13, 0
nop
nop
nop
nop
nop
nop
nop
nop
nop
