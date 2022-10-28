`timescale 1ns/1ps

module neg_tb();

  logic a, b;
  neg neg(a, b);

  initial begin
    a = 0; #10;
    a = 1; #20;
    a = 0; #30;
    a = 1; #40;
    a = 0; #50;
    a = 1; #60;
  end

endmodule
