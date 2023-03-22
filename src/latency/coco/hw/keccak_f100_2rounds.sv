// 2-round keccak-f[100] permutation, used for the load-store-mask generation;
// the 2-round operations are unrolled since the latency is required to be 1-cc


import keccak_pkg::k_plane;
import keccak_pkg::k_state;
import keccak_pkg::N;
import keccak_pkg::ABS;

module keccak_f100_2rounds (
  input   k_state         state_in,
  output  k_state         state_out
);

k_state theta_in_0, theta_out_0, pi_in_0, pi_out_0, rho_in_0, rho_out_0,
        chi_in_0, chi_out_0, iota_in_0, iota_out_0;
k_state theta_in_1, theta_out_1, pi_in_1, pi_out_1, rho_in_1, rho_out_1,
        chi_in_1, chi_out_1, iota_in_1, iota_out_1;

k_plane sum_sheet_0, sum_sheet_1;
logic [N-1:0] rcon_0, rcon_1;

assign  rcon_0       = 4'h1;
assign  rcon_1       = 4'h2;
assign  theta_in_0   = state_in;
assign  pi_in_0      = rho_out_0;
assign  rho_in_0     = theta_out_0;
assign  chi_in_0     = pi_out_0;
assign  iota_in_0    = chi_out_0;
assign  theta_in_1   = iota_out_0;
assign  pi_in_1      = rho_out_1;
assign  rho_in_1     = theta_out_1;
assign  chi_in_1     = pi_out_1;
assign  iota_in_1    = chi_out_1;
assign  state_out    = iota_out_1;


genvar y, x, i;


// round-0 subroutines

// Theta

generate
  for(x = 0; x <= 4; x++)
    for(i = 0; i <= N-1; i++)
      assign sum_sheet_0[x][i] = theta_in_0[0][x][i] ^ theta_in_0[1][x][i] ^ theta_in_0[2][x][i] ^ theta_in_0[3][x][i] ^ theta_in_0[4][x][i];
endgenerate

generate
  for(y = 0; y <= 4; y++)
    for(x = 1; x <= 3; x++) begin
      assign theta_out_0[y][x][0] = theta_in_0[y][x][0] ^ sum_sheet_0[x-1][0] ^ sum_sheet_0[x+1][N-1];
        for(i = 1; i <= N-1; i++)
          assign theta_out_0[y][x][i] = theta_in_0[y][x][i] ^ sum_sheet_0[x-1][i] ^ sum_sheet_0[x+1][i-1];
    end
endgenerate

generate
  for(y = 0; y <= 4; y++) begin
    assign theta_out_0[y][0][0] = theta_in_0[y][0][0] ^ sum_sheet_0[4][0] ^ sum_sheet_0[1][N-1];
      for(i = 1; i <= N-1; i++)
        assign theta_out_0[y][0][i] = theta_in_0[y][0][i] ^ sum_sheet_0[4][i] ^ sum_sheet_0[1][i-1];
  end
endgenerate

generate
  for(y = 0; y <= 4; y++) begin
    assign theta_out_0[y][4][0] = theta_in_0[y][4][0] ^ sum_sheet_0[3][0] ^ sum_sheet_0[0][N-1];
      for(i = 1; i <= N-1; i++)
        assign theta_out_0[y][4][i] = theta_in_0[y][4][i] ^ sum_sheet_0[3][i] ^ sum_sheet_0[0][i-1];
  end
endgenerate


// Rho

always_comb begin
  for(int ri = 0; ri < N; ri++) begin
    rho_out_0[0][0][ri] = rho_in_0[0][0][ri];
    rho_out_0[0][1][ri] = rho_in_0[0][1][ABS((ri-1)  % N)];
    rho_out_0[0][2][ri] = rho_in_0[0][2][ABS((ri-62) % N)];
    rho_out_0[0][3][ri] = rho_in_0[0][3][ABS((ri-28) % N)];
    rho_out_0[0][4][ri] = rho_in_0[0][4][ABS((ri-27) % N)];

    rho_out_0[1][0][ri] = rho_in_0[1][0][ABS((ri-36) % N)];
    rho_out_0[1][1][ri] = rho_in_0[1][1][ABS((ri-44) % N)];
    rho_out_0[1][2][ri] = rho_in_0[1][2][ABS((ri-6)  % N)];
    rho_out_0[1][3][ri] = rho_in_0[1][3][ABS((ri-55) % N)];
    rho_out_0[1][4][ri] = rho_in_0[1][4][ABS((ri-20) % N)];

    rho_out_0[2][0][ri] = rho_in_0[2][0][ABS((ri-3)  % N)];
    rho_out_0[2][1][ri] = rho_in_0[2][1][ABS((ri-10) % N)];
    rho_out_0[2][2][ri] = rho_in_0[2][2][ABS((ri-43) % N)];
    rho_out_0[2][3][ri] = rho_in_0[2][3][ABS((ri-25) % N)];
    rho_out_0[2][4][ri] = rho_in_0[2][4][ABS((ri-39) % N)];

    rho_out_0[3][0][ri] = rho_in_0[3][0][ABS((ri-41) % N)];
    rho_out_0[3][1][ri] = rho_in_0[3][1][ABS((ri-45) % N)];
    rho_out_0[3][2][ri] = rho_in_0[3][2][ABS((ri-15) % N)];
    rho_out_0[3][3][ri] = rho_in_0[3][3][ABS((ri-21) % N)];
    rho_out_0[3][4][ri] = rho_in_0[3][4][ABS((ri-8)  % N)];

    rho_out_0[4][0][ri] = rho_in_0[4][0][ABS((ri-18) % N)];
    rho_out_0[4][1][ri] = rho_in_0[4][1][ABS((ri-2)  % N)];
    rho_out_0[4][2][ri] = rho_in_0[4][2][ABS((ri-61) % N)];
    rho_out_0[4][3][ri] = rho_in_0[4][3][ABS((ri-56) % N)];
    rho_out_0[4][4][ri] = rho_in_0[4][4][ABS((ri-14) % N)];
  end
end


// Pi

generate
  for(y = 0; y <= 4; y++)
    for(x = 0; x <= 4; x++)
      for(i = 0; i <= N-1; i++)
        assign pi_out_0[(2*x+3*y) % 5][0*x+1*y][i] = pi_in_0[y][x][i];
endgenerate


// Chi

generate
  for(y = 0; y <= 4; y++)
    for(x = 0; x <= 2; x++)
      for(i = 0; i <= N-1; i++)
        assign chi_out_0[y][x][i] = chi_in_0[y][x][i] ^ ( ~(chi_in_0[y][x+1][i]) & chi_in_0[y][x+2][i]);
endgenerate

generate
    for(y = 0; y <= 4; y++)
        for(i = 0; i <= N-1; i++)
            assign chi_out_0[y][3][i] = chi_in_0[y][3][i] ^ ( ~(chi_in_0[y][4][i]) & chi_in_0[y][0][i]);
endgenerate

generate
    for(y = 0; y <= 4; y++)
        for(i = 0; i <= N-1; i++)
            assign chi_out_0[y][4][i] = chi_in_0[y][4][i] ^ ( ~(chi_in_0[y][0][i]) & chi_in_0[y][1][i]);
endgenerate


// Iota

generate
    for(y = 1; y <= 4; y++)
        for(x = 0; x <= 4; x++)
            for(i = 0; i <= N-1; i++)
                assign iota_out_0[y][x][i] = iota_in_0[y][x][i];
endgenerate

generate
    for(x = 1; x <= 4; x++)
        for(i = 0; i <= N-1; i++)
            assign iota_out_0[0][x][i] = iota_in_0[0][x][i];
endgenerate

generate
    for(i = 0; i <= N-1; i++)
        assign iota_out_0[0][0][i] = iota_in_0[0][0][i] ^ rcon_0[i];
endgenerate


// round-1 subroutines

// Theta

generate
  for(x = 0; x <= 4; x++)
    for(i = 0; i <= N-1; i++)
      assign sum_sheet_1[x][i] = theta_in_1[0][x][i] ^ theta_in_1[1][x][i] ^ theta_in_1[2][x][i] ^ theta_in_1[3][x][i] ^ theta_in_1[4][x][i];
endgenerate

generate
  for(y = 0; y <= 4; y++)
    for(x = 1; x <= 3; x++) begin
      assign theta_out_1[y][x][0] = theta_in_1[y][x][0] ^ sum_sheet_1[x-1][0] ^ sum_sheet_1[x+1][N-1];
        for(i = 1; i <= N-1; i++)
          assign theta_out_1[y][x][i] = theta_in_1[y][x][i] ^ sum_sheet_1[x-1][i] ^ sum_sheet_1[x+1][i-1];
    end
endgenerate

generate
  for(y = 0; y <= 4; y++) begin
    assign theta_out_1[y][0][0] = theta_in_1[y][0][0] ^ sum_sheet_1[4][0] ^ sum_sheet_1[1][N-1];
      for(i = 1; i <= N-1; i++)
        assign theta_out_1[y][0][i] = theta_in_1[y][0][i] ^ sum_sheet_1[4][i] ^ sum_sheet_1[1][i-1];
  end
endgenerate

generate
  for(y = 0; y <= 4; y++) begin
    assign theta_out_1[y][4][0] = theta_in_1[y][4][0] ^ sum_sheet_1[3][0] ^ sum_sheet_1[0][N-1];
      for(i = 1; i <= N-1; i++)
        assign theta_out_1[y][4][i] = theta_in_1[y][4][i] ^ sum_sheet_1[3][i] ^ sum_sheet_1[0][i-1];
  end
endgenerate


// Rho

always_comb begin
  for(int ri = 0; ri < N; ri++) begin
    rho_out_1[0][0][ri] = rho_in_1[0][0][ri];
    rho_out_1[0][1][ri] = rho_in_1[0][1][ABS((ri-1)  % N)];
    rho_out_1[0][2][ri] = rho_in_1[0][2][ABS((ri-62) % N)];
    rho_out_1[0][3][ri] = rho_in_1[0][3][ABS((ri-28) % N)];
    rho_out_1[0][4][ri] = rho_in_1[0][4][ABS((ri-27) % N)];

    rho_out_1[1][0][ri] = rho_in_1[1][0][ABS((ri-36) % N)];
    rho_out_1[1][1][ri] = rho_in_1[1][1][ABS((ri-44) % N)];
    rho_out_1[1][2][ri] = rho_in_1[1][2][ABS((ri-6)  % N)];
    rho_out_1[1][3][ri] = rho_in_1[1][3][ABS((ri-55) % N)];
    rho_out_1[1][4][ri] = rho_in_1[1][4][ABS((ri-20) % N)];

    rho_out_1[2][0][ri] = rho_in_1[2][0][ABS((ri-3)  % N)];
    rho_out_1[2][1][ri] = rho_in_1[2][1][ABS((ri-10) % N)];
    rho_out_1[2][2][ri] = rho_in_1[2][2][ABS((ri-43) % N)];
    rho_out_1[2][3][ri] = rho_in_1[2][3][ABS((ri-25) % N)];
    rho_out_1[2][4][ri] = rho_in_1[2][4][ABS((ri-39) % N)];

    rho_out_1[3][0][ri] = rho_in_1[3][0][ABS((ri-41) % N)];
    rho_out_1[3][1][ri] = rho_in_1[3][1][ABS((ri-45) % N)];
    rho_out_1[3][2][ri] = rho_in_1[3][2][ABS((ri-15) % N)];
    rho_out_1[3][3][ri] = rho_in_1[3][3][ABS((ri-21) % N)];
    rho_out_1[3][4][ri] = rho_in_1[3][4][ABS((ri-8)  % N)];

    rho_out_1[4][0][ri] = rho_in_1[4][0][ABS((ri-18) % N)];
    rho_out_1[4][1][ri] = rho_in_1[4][1][ABS((ri-2)  % N)];
    rho_out_1[4][2][ri] = rho_in_1[4][2][ABS((ri-61) % N)];
    rho_out_1[4][3][ri] = rho_in_1[4][3][ABS((ri-56) % N)];
    rho_out_1[4][4][ri] = rho_in_1[4][4][ABS((ri-14) % N)];
  end
end


// Pi

generate
  for(y = 0; y <= 4; y++)
    for(x = 0; x <= 4; x++)
      for(i = 0; i <= N-1; i++)
        assign pi_out_1[(2*x+3*y) % 5][0*x+1*y][i] = pi_in_1[y][x][i];
endgenerate


// Chi

generate
  for(y = 0; y <= 4; y++)
    for(x = 0; x <= 2; x++)
      for(i = 0; i <= N-1; i++)
        assign chi_out_1[y][x][i] = chi_in_1[y][x][i] ^ ( ~(chi_in_1[y][x+1][i]) & chi_in_1[y][x+2][i]);
endgenerate

generate
    for(y = 0; y <= 4; y++)
        for(i = 0; i <= N-1; i++)
            assign chi_out_1[y][3][i] = chi_in_1[y][3][i] ^ ( ~(chi_in_1[y][4][i]) & chi_in_1[y][0][i]);
endgenerate

generate
    for(y = 0; y <= 4; y++)
        for(i = 0; i <= N-1; i++)
            assign chi_out_1[y][4][i] = chi_in_1[y][4][i] ^ ( ~(chi_in_1[y][0][i]) & chi_in_1[y][1][i]);
endgenerate


// Iota

generate
    for(y = 1; y <= 4; y++)
        for(x = 0; x <= 4; x++)
            for(i = 0; i <= N-1; i++)
                assign iota_out_1[y][x][i] = iota_in_1[y][x][i];
endgenerate

generate
    for(x = 1; x <= 4; x++)
        for(i = 0; i <= N-1; i++)
            assign iota_out_1[0][x][i] = iota_in_1[0][x][i];
endgenerate

generate
    for(i = 0; i <= N-1; i++)
        assign iota_out_1[0][0][i] = iota_in_1[0][0][i] ^ rcon_1[i];
endgenerate


endmodule
