// use MEM_SECURE by default otherwise bugs
`include "ram_1p_secure.v"
`include "rom_1p.v"
`include "prim_assert.sv"

module ibex_top (clk_sys, rst_sys_n, 
                 instr_we, instr_be, instr_wdata
);
  // Inputs
  input clk_sys;
  input rst_sys_n;
  input instr_we;
  input [3:0] instr_be;
  input [31:0] instr_wdata;

  // Instruction connection to SRAM
  wire        instr_req;
  wire        instr_gnt;
  wire        instr_rvalid;
  wire [31:0] instr_addr;
  wire [31:0] instr_rdata;

  // Data connection to SRAM
  wire        data_req;
  wire        data_gnt;
  wire        data_rvalid;
  wire        data_we;
  wire  [3:0] data_be;
  wire [31:0] data_addr;
  wire [31:0] data_wdata;
  wire [31:0] data_rdata;

  // Ibex core
  ibex_core u_core (
    .rf_sec_bwlogic_first_cycle_o(rf_sec_bwlogic_first_cycle),

    .clk_i                 (clk_sys),
    .rst_ni                (rst_sys_n),

    .hart_id_i             (32'b0),
    .boot_addr_i           (32'h00000000),

    // Instruction memory interface
    .instr_req_o           (instr_req),
    .instr_gnt_i           (instr_gnt),
    .instr_rvalid_i        (instr_rvalid),
    .instr_addr_o          (instr_addr),
    .instr_rdata_i         (instr_rdata),
    .instr_err_i           ('b0),

    // Data memory interface
    .data_req_o            (data_req),
    .data_gnt_i            (data_gnt),
    .data_rvalid_i         (data_rvalid),
    .data_we_o             (data_we),
    .data_be_o             (data_be),
    .data_addr_o           (data_addr),
    .data_wdata_o          (data_wdata),
    .data_rdata_i          (data_rdata),
    .data_err_i            ('b0),

    // Register file interface (new)
    .dummy_instr_id_o      (dummy_instr_id),
    .dummy_instr_wb_o      (dummy_instr_wb),
    .rf_raddr_a_o          (rf_raddr_a),
    .rf_raddr_b_o          (rf_raddr_b),
    .rf_waddr_wb_o         (rf_waddr_wb),
    .rf_we_wb_o            (rf_we_wb),
    .rf_wdata_wb_ecc_o     (rf_wdata_wb_ecc),
    .rf_rdata_a_ecc_i      (rf_rdata_a_ecc),
    .rf_rdata_b_ecc_i      (rf_rdata_b_ecc),

    // RAMs interface (disabled)
    .ic_tag_req_o          (),
    .ic_tag_write_o        (),
    .ic_tag_addr_o         (), 
    .ic_tag_wdata_o        (),
    .ic_tag_rdata_i        ('b0),
    .ic_data_req_o         (),
    .ic_data_write_o       (),
    .ic_data_addr_o        (),
    .ic_data_wdata_o       (),
    .ic_data_rdata_i       ('b0),
    .ic_scr_key_valid_i    ('b0),
    .ic_scr_key_req_o      (),

    // Interrupt inputs
    .irq_software_i        (1'b0),
    .irq_timer_i           (1'b0),
    .irq_external_i        (1'b0),
    .irq_fast_i            (15'b0),
    .irq_nm_i              (1'b0),
    .irq_pending_o         (),

    // Debug Interface
    .debug_req_i           ('b0),
    .crash_dump_o          (),
    .double_fault_seen_o   (),

    // CPU Control Signals
    .fetch_enable_i         ('b1),
    .alert_minor_o          (),
    .alert_major_internal_o (),
    .alert_major_bus_o      (),
    .core_busy_o            (), 
  );  

  // separate SRAM blocks for instruction and data storage
  ram_1p_secure u_ram (
    .clk_i     ( clk_sys      ),
    .rst_ni    ( rst_sys_n    ),
    .req_i     ( data_req     ),
    .we_i      ( data_we      ),
    .be_i      ( data_be      ),
    .addr_i    ( data_addr    ),
    .wdata_i   ( data_wdata   ),
    .rvalid_o  ( data_rvalid  ),
    .rdata_o   ( data_rdata   ),
    .gnt_o     ( data_gnt     )
  );

  rom_1p instr_rom (
    .clk_i     ( clk_sys      ),
    .rst_ni    ( rst_sys_n    ),
    .req_i     ( instr_req    ),
    .we_i      ( instr_we     ),
    .be_i      ( instr_be     ),
    .addr_i    ( instr_addr   ),
    .wdata_i   ( instr_wdata  ),
    .rvalid_o  ( instr_rvalid ),
    .rdata_o   ( instr_rdata  )
  );
  
  always @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      instr_gnt    <= 'b0;
    end else begin
      instr_gnt    <= instr_req;
    end
  end

  // new wires 
  wire        dummy_instr_id;
  wire        dummy_instr_wb;
  wire [ 4:0] rf_raddr_a;
  wire [ 4:0] rf_raddr_b;
  wire [31:0] rf_rdata_a_ecc;
  wire [31:0] rf_rdata_b_ecc;
  wire [ 4:0] rf_waddr_wb;
  wire [31:0] rf_wdata_wb_ecc;
  wire        rf_we_wb;
  wire        rf_sec_bwlogic_first_cycle;

  // register file instantiation 
  ibex_register_file_ff register_file_i (
    .sec_bwlogic_first_cycle_i(rf_sec_bwlogic_first_cycle),

    .clk_i            (clk_sys),
    .rst_ni           (rst_sys_n),

    .test_en_i        ('b0), 
    .dummy_instr_id_i (dummy_instr_id),
    .dummy_instr_wb_i (dummy_instr_wb),

    .raddr_a_i        (rf_raddr_a),
    .rdata_a_o        (rf_rdata_a_ecc),
    .raddr_b_i        (rf_raddr_b),
    .rdata_b_o        (rf_rdata_b_ecc),
    .waddr_a_i        (rf_waddr_wb),
    .wdata_a_i        (rf_wdata_wb_ecc),
    .we_a_i           (rf_we_wb),
    .err_o            ('b0)
  );

endmodule
