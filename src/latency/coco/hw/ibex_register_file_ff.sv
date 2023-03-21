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
`include "secure.sv"

module ibex_register_file #(
    parameter bit RV32E              = 0,
    parameter int unsigned DataWidth = 32
) (
    // Clock and Reset
    input  logic                 clk_i,
    input  logic                 rst_ni,

    input  logic                 test_en_i,
    
    //Read port R1
  `ifdef REGREAD_SECURE
    input logic [31:0]           read_enable_a_i,
  `else
    input  logic [4:0]           raddr_a_i,
  `endif
    output logic [DataWidth-1:0] rdata_a_o,

    //Read port R2
  `ifdef REGREAD_SECURE
    input logic [31:0]           read_enable_b_i,
  `else
    input  logic [4:0]           raddr_b_i,
  `endif    
    output logic [DataWidth-1:0] rdata_b_o,

    // Write port W1
  `ifdef REGWRITE_SECURE
    input logic [31:0] write_enable_secure_i,
  `endif
    input  logic [4:0]           waddr_a_i,
    input  logic [DataWidth-1:0] wdata_a_i,
    input  logic                 we_a_i


);

  localparam int unsigned ADDR_WIDTH = RV32E ? 4 : 5;
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  `ifdef REGWRITE_SECURE
  logic [NUM_WORDS-1:0][DataWidth-1:0] rf_reg;
  logic [NUM_WORDS-1:1][DataWidth-1:0] rf_reg_tmp;
  logic [NUM_WORDS-1:1]                we_a_dec;

  always_comb begin : we_a_decoder
    for (int unsigned i = 1; i < NUM_WORDS; i++) begin
      we_a_dec[i] = (waddr_a_i == 5'(i)) ?  we_a_i : 1'b0;
    end
  end

  // loop from 1 to NUM_WORDS-1 as R0 is nil
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rf_reg_tmp <= '{default:'0};
    end else begin
    // `ifdef REGWRITE_SECURE
      for (int reg_id = 1; reg_id < NUM_WORDS; reg_id++) begin
        for(int bit_id = 0; bit_id < DataWidth; bit_id++) begin
          if (we_a_dec[reg_id]) rf_reg_tmp[reg_id][bit_id] <= (wdata_a_i[bit_id] & write_enable_secure_i[reg_id]);
        end
      end
    // `else 
    //   for (int r = 1; r < NUM_WORDS; r++) begin
    //     if (we_a_dec[r]) rf_reg_tmp[r] <= wdata_a_i;
    //   end
    // `endif
    end
  end
  `else 
  // ++ eliminate 

  logic [DataWidth-1:0] rf_reg [NUM_WORDS+1]; // an extra register to serve as the idle register
  logic [          5:0] rf_idx [NUM_WORDS  ]; // the index list of registers
  logic [          5:0] rf_idle;              // the index of idle register
  logic [NUM_WORDS  :0] we_a_zero;            // to record which register needs to be cleared 
  logic [NUM_WORDS  :0] we_a_idle;            // to record which register is the current idle register
  logic [NUM_WORDS-1:0] we_a_idx;             // to record which entry of the index list needs to be updated
  logic [NUM_WORDS  :0] we_a_ers;             // to record which registers need to be erased

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
      // check which registers need to be erased
      we_a_ers[rf_idx[i]] = sec_ers_i[i];
    end
    we_a_ers[rf_idle] = 1'b0;
  end


  // no flops for R0 as it's hard-wired to 0
  for (genvar i = 1; i < NUM_WORDS+1; i++) begin : g_rf_flops
    logic [DataWidth-1:0] rf_reg_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin 
        rf_reg_q <= '0;
      end else if (we_a_ers[i] | we_a_zero[i]) begin
        rf_reg_q <= '0;             
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

  `endif

  `ifdef REGREAD_SECURE
  // R0 is nil
  assign rf_reg[0] = '0;
  assign rf_reg[NUM_WORDS-1:1] = rf_reg_tmp[NUM_WORDS-1:1];

// `ifdef REGREAD_SECURE
  always_comb begin : reg_read_with_read_enable
    rdata_a_o = 0;
    rdata_b_o = 0;

    for (int reg_id = 0; reg_id < NUM_WORDS; reg_id++) begin
      for(int bit_id = 0; bit_id < DataWidth; bit_id++) begin
        rdata_a_o[bit_id] = rdata_a_o[bit_id] | (rf_reg[reg_id][bit_id] & read_enable_a_i[reg_id]);
        rdata_b_o[bit_id] = rdata_b_o[bit_id] | (rf_reg[reg_id][bit_id] & read_enable_b_i[reg_id]);
      end
    end
  end
// `else
  // assign rdata_a_o = rf_reg[raddr_a_i];
  // assign rdata_b_o = rf_reg[raddr_b_i];
// `endif
  `else 
  // ++ eliminate 

  assign rf_reg[0] = '0;

  assign rdata_a_o = rf_reg[rf_idx[raddr_a_i]]; // read data via the index list 
  assign rdata_b_o = rf_reg[rf_idx[raddr_b_i]]; // read data via the index list
  
  // -- eliminate

  `endif 


endmodule
