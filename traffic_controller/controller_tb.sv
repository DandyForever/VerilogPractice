module controller_tb();
  logic clk, r, ta, tb;
  logic [1:0] y;
  always begin
    clk = 1; #5;
    clk = 0; #5;
  end

  always begin
    ta = 0; tb = 0;
    #7; ta = 0; tb = 1;
    #7; ta = 1; tb = 0;
    #7; ta = 1; tb = 1;
  end

  initial begin
    r = 1;
    #12; r = 0;
  end

  controller controller(r, ta, tb, clk, y);
endmodule
