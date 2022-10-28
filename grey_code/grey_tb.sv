module grey_tb();

  logic clk, r, up;
  logic [2:0] y;
  always begin
    clk = 1; #5;
    clk = 0; #5;
  end

  initial begin
    r = 1;
    #12; r = 0;
    up = 1; #90; up = 0;
  end

  grey grey(clk, r, up, y);

endmodule
