// micro-benchmarks for custom secure instructions

// class-1
// extern void sec_and_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
// extern void sec_andi_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_or_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
// extern void sec_ori_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_xor_test_asm(uint32_t *r, uint32_t *a, uint32_t *b);
// extern void sec_xori_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_slli_test_asm(uint32_t *r, uint32_t *a);
// extern void sec_srli_test_asm(uint32_t *r, uint32_t *a);

// class-2 
// extern void lsmseed_rw_test_asm(uint32_t *r);
// extern void sec_lw_test_asm(uint32_t *r);
// extern void sec_sw_test_asm(uint32_t *r);

// instruction latency measurement
// extern void sec_insn_latency_measurement_asm(uint32_t *r);


// becasue there is a bug in ibex-demo-system re. `rdcycle` instruction; 
// we therefore use `csrr` to read the `mcycle` CSR directly;  
// the address of Machine Cycle Counter (mcycle) CSR is "0xB00"
.macro read_cycle rd 
  csrr \rd, 0xB00 
.endm 


// macros for defination of custom instructions

// class-1

.macro sec.and  rd, rs1, rs2 
 and  \rd, \rs1, \rs2
.endm

.macro sec.andi rd, rs1, rs2 
 andi \rd, \rs1, \rs2
.endm

.macro sec.or   rd, rs1, rs2 
 or   \rd, \rs1, \rs2 
.endm

.macro sec.ori  rd, rs1, rs2 
 ori  \rd, \rs1, \rs2 
.endm

.macro sec.xor  rd, rs1, rs2 
 xor  \rd, \rs1, \rs2 
.endm

.macro sec.xori rd, rs1, rs2 
 xori \rd, \rs1, \rs2 
.endm

.macro sec.slli rd, rs1, imm 
 slli \rd, \rs1, \imm
.endm

.macro sec.srli rd, rs1, imm 
 srli \rd, \rs1, \imm
.endm

// class-2

// Load-Store-Mask SEED (lsmseed) CSR addresses
#define lsmseed0 0x800
#define lsmseed1 0x801
#define lsmseed2 0x802
#define lsmseed3 0x803

// get a Lower-Bit (LB) of the two MSBs
#define LB(x) (x & 1) 
// get a Higher-Bit (HB) of the two MSBs
#define HB(x) ((x>>1) & 1) 

.macro sec.lw  rd, rs1, imm, ms 
.insn i CUSTOM_1, 0, \rd,  \imm+1024*LB(\ms)-2048*HB(\ms)(\rs1)
.endm

.macro sec.sw  rs2, rs1, imm, ms
.insn s CUSTOM_1, 1, \rs2, \imm+1024*LB(\ms)-2048*HB(\ms)(\rs1)
.endm 


// micro-benchmarks

// class-1

.section .text 

.global sec_and_test_asm 

sec_and_test_asm:
  lw       t5, 0(a1)
  lw       t6, 0(a2)
  sec.and  t0, t5, t6
  sw       t0, 0(a0)
  ret 

.global sec_andi_test_asm 

sec_andi_test_asm:
  lw       t5, 0(a1)
  sec.andi t0, t5, 0x0FF
  sw       t0, 0(a0)
  ret 

.global sec_or_test_asm 

sec_or_test_asm:
  lw       t5, 0(a1)
  lw       t6, 0(a2)
  sec.or   t0, t5, t6
  sw       t0, 0(a0)
  ret 

.global sec_ori_test_asm 

sec_ori_test_asm:
  lw       t5, 0(a1)
  sec.ori  t0, t5, 0x0FF
  sw       t0, 0(a0)
  ret 

.global sec_xor_test_asm 

sec_xor_test_asm:
  lw       t5, 0(a1)
  lw       t6, 0(a2)
  sec.xor  t0, t5, t6
  sw       t0, 0(a0)
  ret 

.global sec_xori_test_asm 

sec_xori_test_asm:
  lw       t5, 0(a1)
  sec.xori t0, t5, -1
  sw       t0, 0(a0)
  ret

.global sec_slli_test_asm 

sec_slli_test_asm:
  lw       t5, 0(a1)
  sec.slli t0, t5, 4
  sw       t0, 0(a0)
  ret 

.global sec_srli_test_asm 

sec_srli_test_asm:
  lw       t5, 0(a1)
  sec.srli t0, t5, 4
  sw       t0, 0(a0)
  ret 

// class-2

.global lsmseed_rw_test_asm

lsmseed_rw_test_asm:
  li       t0, 0x1
  csrrw    x0, lsmseed0, t0
  csrr     t1, lsmseed0
  sw       t1,  0(a0)
  li       t0, 0x22
  csrrw    x0, lsmseed1, t0
  csrr     t1, lsmseed1
  sw       t1,  4(a0)
  li       t0, 0x333
  csrrw    x0, lsmseed2, t0
  csrr     t1, lsmseed2
  sw       t1,  8(a0)
  li       t0, 0x4444
  csrrw    x0, lsmseed3, t0
  csrr     t1, lsmseed3
  sw       t1, 12(a0)
  ret

.global sec_sw_test_asm
sec_sw_test_asm:
  li       t0, 0x11
  csrrw    x0, lsmseed0, t0
  li       t0, 0x2222
  csrrw    x0, lsmseed1, t0
  li       t0, 0x11
  csrrw    x0, lsmseed2, t0
  li       t0, 0x44444444
  csrrw    x0, lsmseed3, t0  
  li       t1, 0x01234567
  li       t2, 0x89ABCDEF
  sec.sw   t1, a0,  0, 0
  sec.sw   t2, a0,  4, 1
  sec.sw   t1, a0,  8, 2
  sec.sw   t2, a0, 12, 3
  ret

.global sec_lw_test_asm 
sec_lw_test_asm:
  li       t0, 0x11
  csrrw    x0, lsmseed0, t0
  li       t0, 0x2222
  csrrw    x0, lsmseed1, t0
  li       t0, 0x11
  csrrw    x0, lsmseed2, t0
  li       t0, 0x44444444
  csrrw    x0, lsmseed3, t0  
  sec.lw   t1, a0, 0, 0
  sw       t1, 0(a0)
  sec.lw   t1, a0, 4, 1
  sw       t1, 4(a0)
  sec.lw   t1, a0, 8, 2
  sw       t1, 8(a0)
  sec.lw   t1, a0,12, 3
  sw       t1, 12(a0)
  ret

// instruction latency measurement

.global sec_insn_latency_measurement_asm
sec_insn_latency_measurement_asm: 
  // `sec.and`
  read_cycle t0 
  sec.and    t2, t3, t4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0,  0(a0)

  // `sec.andi`
  read_cycle t0 
  sec.andi   t2, t3, 0x0FF 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0,  4(a0) 

  // `sec.or`
  read_cycle t0 
  sec.or     t2, t3, t4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0,  8(a0) 

  // `sec.ori`
  read_cycle t0 
  sec.ori    t2, t3, 0x0FF 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 12(a0) 

  // `sec.xor`
  read_cycle t0 
  sec.xor    t2, t3, t4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 16(a0) 

  // `sec.xori`
  read_cycle t0 
  sec.xori   t2, t3, 0x0FF 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 20(a0)

  // `sec.slli`
  read_cycle t0 
  sec.slli   t2, t3, 4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 24(a0)

  // `sec.srli`
  read_cycle t0 
  sec.srli   t2, t3, 4 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 28(a0)

  // `sec.sw`
  read_cycle t0 
  sec.sw     t2, a0, 32, 0 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 32(a0)

  // `sec.lw`
  read_cycle t0 
  sec.lw     t2, a0, 36, 1 
  read_cycle t1
  sub        t0, t1, t0 
  addi       t0, t0, -1  // `csrr` itself takes 1 cycle, which needs to be subtracted
  sw         t0, 36(a0)

  ret 
