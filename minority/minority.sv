module minority(
    input logic a, b, c,
    output logic y
);

  always_comb begin
    casez({a, b, c})
      3'b?00:  y = 1;
      3'b0?0:  y = 1;
      3'b00?:  y = 1;
      default: y = 0;
    endcase
  end

endmodule
