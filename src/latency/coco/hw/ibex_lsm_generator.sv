
module ibex_lsm_generator (
  input  logic [31:0]  data_addr_i,
  input  logic [31:0]  lsmseed_i,
  output logic [31:0]  data_lsm_o
);

  import keccak_pkg::k_state;

  k_state state_in, state_out;
  logic [63:0] data_i;
  
  assign data_i = {lsmseed_i[31:0], data_addr_i[31:0]};

  genvar x, y, i;

  // 1) initialize the state_in with memory address and the seed; 
  //    64 LSBs of the state are seed+memory_address;
  //    36 MSBs of the state are 0s

  generate
    for (y = 0; y <= 2; y++) 
      for (x = 0; x <= 4; x++) 
        for (i = 0; i <= 3; i++)
          assign state_in[y][x][i] = data_i[5*4*y+4*x+i];
  endgenerate

  generate
    for (i = 0; i <= 3; i++)
      assign state_in[3][0][i] = data_i[60+i];
  endgenerate

  generate
    for (x = 1; x <= 4; x++) 
      for (i = 0; i <= 3; i++)
        assign state_in[3][x][i] = '0;
  endgenerate

  generate
    for (x = 0; x <= 4; x++) 
      for (i = 0; i <= 3; i++)
        assign state_in[4][x][i] = '0;
  endgenerate

  // 2) permute the state

  keccak_f100_2rounds keccak_f100_2rounds_i (
    .state_in(state_in),
    .state_out(state_out)
  );

  // 3) derive the mask from the state_out;
  //    mask is 64 LSBs of the state

  generate
    for (x = 0; x <= 4; x++) 
      for (i = 0; i <= 3; i++) 
        assign data_lsm_o[4*x+i] = state_out[0][x][i];
  endgenerate

  generate
    for (x = 0; x <= 2; x++) 
      for (i = 0; i <= 3; i++) 
        assign data_lsm_o[20+4*x+i] = state_out[1][x][i];
  endgenerate

  // unused strobe
  logic [3:0]  unused_strobe0, unused_strobe1;
  logic [19:0] unused_strobe2, unused_strobe3, unused_strobe4;
  assign unused_strobe0[3:0]  = state_out[1][3];
  assign unused_strobe1[3:0]  = state_out[1][4];
  assign unused_strobe2[19:0] = state_out[2];
  assign unused_strobe3[19:0] = state_out[3];
  assign unused_strobe4[19:0] = state_out[4];
endmodule
