module controller(
    input logic r, ta, tb, clk,
    output logic [1:0] y
);

  logic [1:0] state, next_state;
  parameter s0 = 2'b00;
  parameter s1 = 2'b01;
  parameter s2 = 2'b10;
  parameter s3 = 2'b11;

  always_ff @(posedge clk, posedge r)
    if (r) state <= s0;
    else   state <= next_state;

  always_comb
    casez (state)
      s0: next_state = ta ? s0 : s1;
      s1: next_state = s2;
      s2: next_state = tb ? s2 : s3;
      s3: next_state = s0;
      default: next_state = s0;
    endcase

  assign y = state;

endmodule
