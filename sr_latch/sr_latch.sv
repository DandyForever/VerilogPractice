module sr_latch(
    input logic s, r,
    output logic q
);
  always_latch begin
    if (s) q <= 1;
    if (r) q <= 0;
  end
endmodule
