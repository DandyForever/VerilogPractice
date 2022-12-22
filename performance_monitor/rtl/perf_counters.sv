`default_nettype none

module perf_counters #(
  CNT_W  = 16,
  CC_N   = 6,
  SC_N   = 4,
  CNT_N  = SC_N + CC_N,
  MODE_W = 2
)(
  input logic clk_i,
  input logic reset_i,

  input logic [SC_N-1:0]signal_i,

  input logic [CC_N-1:0]axis_tvalid_i,
  input logic [CC_N-1:0]axis_tready_i,
  input logic [CC_N-1:0]axis_tlast_i,

  input logic cmd_we_i,
  input logic en_i,
  input logic clear_i,
  input logic save_i,
  input logic [MODE_W-1:0]mode_i,

  output logic [CNT_N-1:0][CNT_W-1:0]cnt_val_o,
  output logic [CNT_N-1:0]           ovf_o
);

  genvar j;

  for (j = 0; j < SC_N; j++) begin
    static_counter #(
      .CNT_W(CNT_W)
    ) sc (
      .clk_i    (clk_i       ),
      .reset_i  (reset_i     ),
      .signal_i (signal_i [j]),
      .cmd_we_i (cmd_we_i    ),
      .en_i     (en_i        ),
      .clear_i  (clear_i     ),
      .save_i   (save_i      ),
      .cnt_val_o(cnt_val_o[j]),
      .ovf_o    (ovf_o    [j])
    );
  end

  for (j = 0; j < CC_N; j++) begin
    conf_counter #(
      .CNT_W (CNT_W ),
      .MODE_W(MODE_W)
    ) cc (
      .clk_i        (clk_i            ),
      .reset_i      (reset_i          ),
      .axis_tvalid_i(axis_tvalid_i[j] ),
      .axis_tready_i(axis_tready_i[j] ),
      .axis_tlast_i (axis_tlast_i [j] ),
      .cmd_we_i     (cmd_we_i         ),
      .en_i         (en_i             ),
      .clear_i      (clear_i          ),
      .save_i       (save_i           ),
      .mode_i       (mode_i           ),
      .cnt_val_o    (cnt_val_o[j+SC_N]),
      .ovf_o        (ovf_o    [j+SC_N])
    );
  end

endmodule

`default_nettype wire
