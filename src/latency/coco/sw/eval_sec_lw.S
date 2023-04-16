# this micro-benchmark should work with the label file `eliminate-label.txt`

.macro sec.sw  rs2, rs1, imm, ms
.insn s CUSTOM_1, 1, \rs2, \imm+1024*(\ms&1)-2048*((\ms>>1)&1)(\rs1)
.endm 

.macro sec.lw  rd, rs1, imm, ms 
.insn i CUSTOM_1, 0, \rd,  \imm+1024*(\ms&1)-2048*((\ms>>1)&1)(\rs1)
.endm

.org 0x80
nop
li       x13, 0x20
csrrw    x0,  0x800, x7    # initialize lsmseed0 CSR
sec.sw   x5,  x13, 0, 0
and      x6,  x6, x6
# overwrite a (masked) share with another (masked) share to check if there's now 
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
