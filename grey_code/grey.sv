module grey(
    input logic clk,
    input logic r,
    input logic up,
    output logic [2:0] y
);

  logic [2:0] state, next_state;
  parameter s0 = 3'b000;
  parameter s1 = 3'b001;
  parameter s2 = 3'b011;
  parameter s3 = 3'b010;
  parameter s4 = 3'b110;
  parameter s5 = 3'b111;
  parameter s6 = 3'b101;
  parameter s7 = 3'b100;

  always_ff @(posedge clk, posedge r)
    if (r) state <= s0;
    else   state <= next_state;

  always_comb
    casez (state)
      s0: next_state <= up ? s1 : s7;
      s1: next_state <= up ? s2 : s0;
      s2: next_state <= up ? s3 : s1;
      s3: next_state <= up ? s4 : s2;
      s4: next_state <= up ? s5 : s3;
      s5: next_state <= up ? s6 : s4;
      s6: next_state <= up ? s7 : s5;
      s7: next_state <= up ? s0 : s6;
      default: next_state <= s0;
    endcase

  assign y = state;

endmodule
