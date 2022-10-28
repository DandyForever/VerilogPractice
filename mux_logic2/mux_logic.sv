module logical_expression(
    input logic a, b, c,
    output logic y
);

  mux4 out({b, c}, 0, a, 1, 0, y);

endmodule
