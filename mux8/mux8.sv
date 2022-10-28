module mux2
    #(parameter W = 3)
    (input logic s,
    input logic [W - 1:0] d0,
    input logic [W - 1:0] d1,
    output logic [W - 1:0] y);
  assign y = s ? d1 : d0;
endmodule

module mux4
    #(parameter W = 3)
    (input logic [1:0] s,
    input logic [W - 1:0] d0,
    input logic [W - 1:0] d1,
    input logic [W - 1:0] d2,
    input logic [W - 1:0] d3,
    output logic [W - 1:0] y);
  logic [W - 1:0] lower;
  logic [W - 1:0] upper;
  mux2 #(W) lower_mux(s[0], d0, d1, lower);
  mux2 #(W) upper_mux(s[0], d2, d3, upper);
  mux2 #(W) out(s[1], lower, upper, y);
endmodule

module mux8
    #(parameter W = 3)
    (input logic [2:0] s,
    input logic [W - 1:0] d0,
    input logic [W - 1:0] d1,
    input logic [W - 1:0] d2,
    input logic [W - 1:0] d3,
    input logic [W - 1:0] d4,
    input logic [W - 1:0] d5,
    input logic [W - 1:0] d6,
    input logic [W - 1:0] d7,
    output logic [W - 1:0] y);
  logic [W - 1:0] lower;
  logic [W - 1:0] upper;
  mux4 #(W) lower_mux(s[1:0], d0, d1, d2, d3, lower);
  mux4 #(W) upper_mux(s[1:0], d4, d5, d6, d7, upper);
  mux2 #(W) out(s[2], lower, upper, y);
endmodule
