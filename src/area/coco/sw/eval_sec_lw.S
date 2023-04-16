# this micro-benchmark should work with the label file `eliminate-label.txt`

# the following commented case (i.e., using normal `lw`) doesn't pass the test
# sw       x5,  0(x13)
# and      x6, x6, x6
# lw      x12,  0(x13)

# now to test the case using secure load (i.e., `sec.lw`)

.macro sec.lw  rd, rs1, imm, ms 
.insn i CUSTOM_1, 0, \rd,  \imm+1024*(\ms&1)-2048*((\ms>>1)&1)(\rs1)
.endm

.org 0x80
nop
li       x13, 0x20
sw       x5,  0(x13)
# overwrite a share with another share to check if there's now 
# an architecutral leakage and/or a micro-architectural leakage
sec.lw   x12, x13, 0, 0
nop
nop
nop
nop
nop
nop
nop
nop
nop
