module logical_expression(
    input logic a, b, c,
    output logic y);
  mux8 out({a, b, c}, 0, 0, 1, 0, 0, 1, 1, 0, y);
endmodule
