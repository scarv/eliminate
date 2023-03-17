
package keccak_pkg;

  parameter int NUM_PLANE             = 5;
  parameter int NUM_SHEET             = 5;
  parameter int unsigned N            = 4;


  typedef logic   [N-1:0]             k_lane;
  typedef k_lane  [NUM_SHEET-1:0]     k_plane;
  typedef k_plane [NUM_PLANE-1:0]     k_state;


  function int ABS (int numberIn);
    ABS = (numberIn < 0) ? -numberIn : numberIn;
  endfunction

endpackage
