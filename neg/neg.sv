`timescale 1ns/1ps

module neg(
  input logic x,
  output logic y
);

assign y = ~x;

endmodule
