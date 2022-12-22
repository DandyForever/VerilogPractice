`default_nettype none

module conf_counter #(
  parameter CNT_W  = 16,
  parameter MODE_W = 2
)(
  input logic clk_i,
  input logic reset_i,

  input logic axis_tvalid_i,
  input logic axis_tready_i,
  input logic axis_tlast_i,

  input logic             cmd_we_i,
  input logic             en_i,
  input logic             clear_i,
  input logic             save_i,
  input logic [MODE_W-1:0]mode_i,

  output logic [CNT_W-1:0]cnt_val_o,
  output logic            ovf_o
);

  logic [MODE_W-1:0]mode_ff;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      mode_ff <= {MODE_W{1'b0}};
    end else begin
      mode_ff <= cmd_we_i ? mode_i : mode_ff;
    end
  end

  logic tlast_ff;
  logic tlast_next;

  always_comb begin
    casez (tlast_ff)
      1'b0:    tlast_next = axis_tlast_i;
      1'b1:    tlast_next = 1'b0;
      default: tlast_next = 1'b0;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      tlast_ff <= 1'b0;
    end else begin
      tlast_ff <= tlast_next;
    end
  end

  logic is_incr;

  always_comb begin
    casez (mode_ff)
      2'b00: is_incr = axis_tvalid_i && axis_tready_i;
      2'b01: is_incr = tlast_ff;
      2'b10: is_incr = axis_tvalid_i && ~axis_tready_i;
      2'b11: is_incr = ~axis_tvalid_i;
      default: is_incr = 1'b0;
    endcase
  end

  static_counter #(
    .CNT_W(CNT_W)
  ) counter (
    .clk_i    (clk_i    ),
    .reset_i  (reset_i  ),
    .signal_i (is_incr  ),
    .cmd_we_i (cmd_we_i ),
    .en_i     (en_i     ),
    .clear_i  (clear_i  ),
    .save_i   (save_i   ),
    .cnt_val_o(cnt_val_o),
    .ovf_o    (ovf_o    )
  );

endmodule

`default_nettype wire
