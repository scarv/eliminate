# Encoding of custom instructions

<!--- ==================================================================== --->

## Area-optimised version

### Class-1: bitwise logical operation

```
# bitwise and (register-register)
.macro sec.and  rd, rs1, rs2 
.insn r CUSTOM_0, 0, 0, \rd, \rs1, \rs2
.endm

# bitwise and (register-immediate)
.macro sec.andi rd, rs1, imm 
.insn i CUSTOM_0, 1, \rd, \rs1, \imm
.endm

# bitwise or (register-register)
.macro sec.or   rd, rs1, rs2 
.insn r CUSTOM_0, 2, 0, \rd, \rs1, \rs2
.endm

# bitwise or (register-immediate)
.macro sec.ori  rd, rs1, imm 
.insn i CUSTOM_0, 3, \rd, \rs1, \imm
.endm

# bitwise xor (register-register)
.macro sec.xor  rd, rs1, rs2 
.insn r CUSTOM_0, 4, 0, \rd, \rs1, \rs2
.endm

# bitwise xor (register-immediate)
.macro sec.xori rd, rs1, imm 
.insn i CUSTOM_0, 5, \rd, \rs1, \imm
.endm

# bitwise left-shift
.macro sec.slli rd, rs1, imm 
.insn i CUSTOM_0, 6, \rd, \rs1, \imm
.endm

# bitwise right-shift
.macro sec.srli rd, rs1, imm 
.insn i CUSTOM_0, 7, \rd, \rs1, \imm
.endm

```

### Class-2: memory access

```
# get a Lower-Bit (LB)
#define LB(x) (x & 1) 
# get a Higher-Bit (HB)
#define HB(x) ((x>>1) & 1) 

# load a word from RAM (ms selects the lsmseed CSR to be used)
.macro sec.lw  rd, rs1, imm, ms 
.insn i CUSTOM_1, 0, \rd,  \imm+1024*LB(\ms)-2048*HB(\ms)(\rs1)
.endm

# store a word to RAM (ms selects the lsmseed CSR to be used)
.macro sec.sw  rs2, rs1, imm, ms
.insn s CUSTOM_1, 1, \rs2, \imm+1024*LB(\ms)-2048*HB(\ms)(\rs1)
.endm 
```

<!--- ==================================================================== --->

## Latency-optimised version

### Class-1: bitwise logical operation (the same as RV32I instructions)

```
.macro sec.and  rd, rs1, rs2 
 and  \rd, \rs1, \rs2
.endm

.macro sec.andi rd, rs1, imm 
 andi \rd, \rs1, \imm
.endm

.macro sec.or   rd, rs1, rs2 
 or   \rd, \rs1, \rs2 
.endm

.macro sec.ori  rd, rs1, imm 
 ori  \rd, \rs1, \imm
.endm

.macro sec.xor  rd, rs1, rs2
 xor  \rd, \rs1, \rs2 
.endm

.macro sec.xori rd, rs1, imm 
 xori \rd, \rs1, \imm
.endm

.macro sec.slli rd, rs1, imm 
 slli \rd, \rs1, \imm
.endm

.macro sec.srli rd, rs1, imm 
 srli \rd, \rs1, \imm
.endm
```

### Class-2: memory access

```
# get a Lower-Bit (LB)
#define LB(x) (x & 1) 
# get a Higher-Bit (HB)
#define HB(x) ((x>>1) & 1) 

# load a word from RAM (ms selects the lsmseed CSR to be used)
.macro sec.lw  rd, rs1, imm, ms 
.insn i CUSTOM_1, 0, \rd,  \imm+1024*LB(\ms)-2048*HB(\ms)(\rs1)
.endm

# store a word to RAM (ms selects the lsmseed CSR to be used)
.macro sec.sw  rs2, rs1, imm, ms
.insn s CUSTOM_1, 1, \rs2, \imm+1024*LB(\ms)-2048*HB(\ms)(\rs1)
.endm 
```

- There are four load-store-mask seed (`lsmseed`) CSRs used by class-2 instructions, 
whose addresses are defined as follows (see Table 2.1 of [The RISC-V Instruction Set Manual
Volume II: Privileged Architecture](https://github.com/riscv/riscv-isa-manual/releases/download/Priv-v1.12/riscv-privileged-20211203.pdf) which defines the use and accessibility of different CSR addresses):
```
#define lsmseed0 0x800
#define lsmseed1 0x801
#define lsmseed2 0x802
#define lsmseed3 0x803
```

- In order to use the class-2 instructions properly, 
the masked implementation developer has to intiliase the `lsmseed` CSRs in the prologue of the assembler code, 
e.g., 
```
# t0-t3 hold four different random nonces
csrrw    x0, lsmseed0, t0
csrrw    x0, lsmseed1, t1
csrrw    x0, lsmseed2, t2
csrrw    x0, lsmseed3, t3
``` 

<!--- ==================================================================== --->
