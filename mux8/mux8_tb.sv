module mux8_tb();
  logic clk, reset;
  logic [2:0] s;
  logic [2:0] d0, d1, d2, d3, d4, d5, d6, d7;
  logic [2:0] y, y_exp;
  logic [31:0] vectornum, errors;
  logic [5:0] testvectors[31:0];

  mux8 mux8(s, d0, d1, d2, d3, d4, d5, d6, d7, y);

  always begin
    clk = 1; #10;
    clk = 0; #10;
  end

  initial begin
    $readmemb("../mux8_tb.dat", testvectors);
    vectornum = 0; errors = 0;
    reset = 0; #15; reset = 1;
    d0 = 3'b101; d1 = 3'b001;
    d2 = 3'b010; d3 = 3'b011;
    d4 = 3'b100; d5 = 3'b101;
    d6 = 3'b110; d7 = 3'b111;
    y_exp = 3'b111; s  = 3'b100;
  end

  always @(posedge clk) begin
    if (reset)
      #1; {s, y_exp} = testvectors[vectornum];
  end

  always @(negedge clk) begin
    if (reset) begin
      if (y != y_exp) begin
        $display("Error: inputs = %b", s);
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
