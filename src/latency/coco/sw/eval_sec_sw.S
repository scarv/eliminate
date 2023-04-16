# this micro-benchmark should work with the label file `eliminate-label.txt`

# the following commented case (i.e., using normal `sw`) doesn't pass the test
# sw       x5,  0(x13)
# and      x6, x6, x6
# sw      x12,  0(x13)

# now to test the case using secure store (i.e., `sec.sw`)

.macro sec.sw  rs2, rs1, imm, ms
.insn s CUSTOM_1, 1, \rs2, \imm+1024*(\ms&1)-2048*((\ms>>1)&1)(\rs1)
.endm 

.org 0x80
nop
li       x13, 0x20
csrrw    x0,  0x800, x6   # initialize lsmseed0 CSR
csrrw    x0,  0x801, x7   # initialize lsmseed1 CSR
sec.sw   x5,  x13, 0, 0   # store a share to 0x20
and      x6,  x6, x6      
# overwrite a (masked) share with another (masked) share to check if there's now 
# an architecutral leakage and/or a micro-architectural leakage
sec.sw   x12, x13, 0, 1   # store to the same address but use a different load-store-mask
nop
nop
nop
nop
nop
nop
nop
nop
nop
