module minority_tb();
  logic clk, reset;
  logic a, b, c;
  logic y_exp, y;
  logic [31:0] vectornum, errors;
  logic [3:0] testvectors[31:0];

  minority minority(a, b, c, y);

  always begin
    clk = 1; #10;
    clk = 0; #10;
  end

  initial begin
    $readmemb("minority_tb.dat", testvectors);
    vectornum = 0; errors = 0;
  end

  always @(posedge clk) begin
    #1; {a, b, c, y_exp} = testvectors[vectornum];
  end

  always @(negedge clk) begin
    if (y != y_exp) begin
      $display("Error: inputs = %b", {a, b, c});
      $display(" outputs = %b {%b expected}", y, y_exp);
      errors = errors + 1;
    end
    vectornum = vectornum + 1;
    if (testvectors[vectornum] === 4'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
  end
endmodule
