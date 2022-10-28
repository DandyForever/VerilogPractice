module decoder_tb();

  logic clk, reset;
  logic [1:0] a;
  logic [3:0] y, y_exp;
  logic [31:0] vectornum, errors;
  logic [5:0] testvectors[1000:0];

  decoder decoder(a, y);

  always begin
    clk = 1; #10;
    clk = 0; #10;
  end

  initial begin
    $readmemb("../decoder_tb.dat", testvectors);
    vectornum = 0; errors = 0;
    reset = 0;
    #15; reset = 1;
  end

  always @(posedge clk) begin
    #1; {a, y_exp} = testvectors[vectornum];
  end

  always @(negedge clk) begin
    if (reset) begin
      if (y != y_exp) begin
        $display("Error: inputs = %b", a);
        $display(" outputs = %b {%b expected}", y, y_exp);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 6'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
  end

endmodule
