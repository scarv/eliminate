// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31 or 15x 32 bit wide registers. Register 0 is fixed to 0.
 * This register file is based on flip flops. Use this register file when
 * targeting FPGA synthesis or Verilator simulation.
 */
module ibex_register_file_ff #(
  parameter bit                   RV32E             = 0,
  parameter int unsigned          DataWidth         = 32,
  parameter bit                   DummyInstructions = 0,
  parameter bit                   WrenCheck         = 0,
  parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,
  input  logic                 dummy_instr_id_i,
  input  logic                 dummy_instr_wb_i,

  //Read port R1
  input  logic [4:0]           raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,

  //Read port R2
  input  logic [4:0]           raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,


  // Write port W1
  input  logic [4:0]           waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i,

  // This indicates whether spurious WE are detected.
  output logic                 err_o
);

  localparam int unsigned ADDR_WIDTH = RV32E ? 4 : 5;
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  // ++ eliminate 

  // logic [DataWidth-1:0] rf_reg   [NUM_WORDS];
  // logic [NUM_WORDS-1:0] we_a_dec;

  // always_comb begin : we_a_decoder
  //   for (int unsigned i = 0; i < NUM_WORDS+1; i++) begin
  //     we_a_dec[i] = (waddr_a_i == 5'(i)) ? we_a_i : 1'b0;
  //   end
  // end

  logic [DataWidth-1:0] rf_reg [NUM_WORDS+1]; // an extra register to serve as the idle register
  logic [          5:0] rf_idx [NUM_WORDS  ]; // the index list of registers
  logic [          5:0] rf_idle;              // the index of idle register
  logic [NUM_WORDS  :0] we_a_zero;            // to record which register needs to be cleared 
  logic [NUM_WORDS  :0] we_a_idle;            // to record which register is the current idle register
  logic [NUM_WORDS-1:0] we_a_idx;             // to record which entry of the index list needs to be updated

  always_comb begin : we_a_decoder
    for (int unsigned i = 1; i < NUM_WORDS+1; i++) begin
      // check which register needs to be cleared
      we_a_zero[i] = (rf_idx[waddr_a_i] == 6'(i)) ? we_a_i : 1'b0;
      // check which register is the current idle register
      we_a_idle[i] = (rf_idle           == 6'(i)) ? we_a_i : 1'b0;
    end
  end

  always_comb begin: we_a_idx_decoder
    for (int unsigned i = 1; i < NUM_WORDS; i++) begin 
      // check which entry of the index list needs to be updated 
      we_a_idx[i]  = (waddr_a_i == 5'(i)) ? we_a_i : 1'b0;
    end
  end

  // -- eliminate 

  // SEC_CM: DATA_REG_SW.GLITCH_DETECT
  // This checks for spurious WE strobes on the regfile.
  if (WrenCheck) begin : gen_wren_check
    // Buffer the decoded write enable bits so that the checker
    // is not optimized into the address decoding logic.
    // logic [NUM_WORDS-1:0] we_a_dec_buf;
    // prim_buf #(
    //   .Width(NUM_WORDS)
    // ) u_prim_buf (
    //   .in_i(we_a_dec),
    //   .out_o(we_a_dec_buf)
    // );

    // prim_onehot_check #(
    //   .AddrWidth(ADDR_WIDTH),
    //   .AddrCheck(1),
    //   .EnableCheck(1)
    // ) u_prim_onehot_check (
    //   .clk_i,
    //   .rst_ni,
    //   .oh_i(we_a_dec_buf),
    //   .addr_i(waddr_a_i),
    //   .en_i(we_a_i),
    //   .err_o
    // );
  end else begin : gen_no_wren_check
    // ++ eliminate 
    // logic unused_strobe;
    // assign unused_strobe = we_a_dec[0]; // this is never read from in this case
    logic unused_strobe0, unused_strobe1, unused_strobe2; // unused strobes 
    assign unused_strobe0 = we_a_zero[0];
    assign unused_strobe1 = we_a_idle[0];
    assign unused_strobe2 = we_a_idx[0];
    // -- eliminate

    assign err_o = 1'b0;
  end

  // ++ eliminate 

  // No flops for R0 as it's hard-wired to 0
  // for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_flops
  //   logic [DataWidth-1:0] rf_reg_q;

  //   always_ff @(posedge clk_i or negedge rst_ni) begin
  //     if (!rst_ni) begin
  //       rf_reg_q <= WordZeroVal;
  //     end else if (we_a_dec[i]) begin
  //       rf_reg_q <= wdata_a_i;
  //     end
  //   end

  //   assign rf_reg[i] = rf_reg_q;
  // end

  // no flops for R0 as it's hard-wired to 0
  for (genvar i = 1; i < NUM_WORDS+1; i++) begin : g_rf_flops
    logic [DataWidth-1:0] rf_reg_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin 
        rf_reg_q <= WordZeroVal;
      end else if (we_a_zero[i]) begin
        rf_reg_q <= WordZeroVal;             
      end else if (we_a_idle[i]) begin
        rf_reg_q <= wdata_a_i; 
      end
    end

    assign rf_reg[i] = rf_reg_q;
  end

  // the 0-th entry of the index list (needed by "read data") is always R0 
  assign rf_idx[0] = '0;

  // no flops for rf_idx[0] as it (also R0) is hard-wired to 0
  for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_idx
    logic [5:0] rf_idx_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin 
        rf_idx_q <= 6'(i);
      end else if (we_a_idx[i]) begin 
        rf_idx_q <= rf_idle;
      end
    end

    assign rf_idx[i] = rf_idx_q;
  end

  logic [5:0] rf_idle_q;

  // update the index of idle register 
  // iff "write is enabled" and "destination register is not R0" 
  always_ff @(posedge clk_i or negedge rst_ni) begin : g_rf_idle
    if (!rst_ni) begin 
      rf_idle_q <= 6'(NUM_WORDS);  
    end else if ((we_a_i) & (waddr_a_i != 5'b0)) begin
      rf_idle_q <= rf_idx[waddr_a_i];
    end
  end
  
  assign rf_idle = rf_idle_q;

  // -- eliminate

  // With dummy instructions enabled, R0 behaves as a real register but will always return 0 for
  // real instructions.
  if (DummyInstructions) begin : g_dummy_r0
    // SEC_CM: CTRL_FLOW.UNPREDICTABLE
    logic                 we_r0_dummy;
    logic [DataWidth-1:0] rf_r0_q;

    // Write enable for dummy R0 register (waddr_a_i will always be 0 for dummy instructions)
    assign we_r0_dummy = we_a_i & dummy_instr_wb_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rf_r0_q <= WordZeroVal;
      end else if (we_r0_dummy) begin
        rf_r0_q <= wdata_a_i;
      end
    end

    // Output the dummy data for dummy instructions, otherwise R0 reads as zero
    assign rf_reg[0] = dummy_instr_id_i ? rf_r0_q : WordZeroVal;

  end else begin : g_normal_r0
    logic unused_dummy_instr;
    assign unused_dummy_instr = dummy_instr_id_i ^ dummy_instr_wb_i;

    // R0 is nil
    assign rf_reg[0] = WordZeroVal;
  end

  // ++ eliminate 
  // assign rdata_a_o = rf_reg[raddr_a_i];
  // assign rdata_b_o = rf_reg[raddr_b_i];
  assign rdata_a_o = rf_reg[rf_idx[raddr_a_i]]; // read data via the index list 
  assign rdata_b_o = rf_reg[rf_idx[raddr_b_i]]; // read data via the index list
  // -- eliminate   

  // Signal not used in FF register file
  logic unused_test_en;
  assign unused_test_en = test_en_i;

endmodule
