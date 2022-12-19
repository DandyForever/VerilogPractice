`default_nettype none

module performance_monitor #(
  parameter AXIS_DIN_W = 8,
  parameter CMD_W      = 3000,
  parameter N_EU       = 8'd3,
  parameter ID_W       = 8,
  parameter CU_ID      = 8'b0,
  parameter [ID_W-1:0]EU_ID[N_EU-1:0] = {8'd1, 8'd2, 8'd3},
  parameter CLK_CNT_W  = 32,
  parameter CLK_VAL    = 32'h1000
)(
  input logic clk_i,
  input logic reset_i
);

  logic                 axis_tvalid[N_EU:0];
  logic                 axis_tready[N_EU:0];
  logic                 axis_tlast [N_EU:0];
  logic [AXIS_DIN_W-1:0]axis_tdata [N_EU:0];

  cu_controller #(
    .AXIS_DIN_W(AXIS_DIN_W),
    .CMD_W     (CMD_W     ),
    .ID        (CU_ID     ),
    .ID_W      (ID_W      ),
    .N_EU      (N_EU      ),
    .CLK_CNT_W (CLK_CNT_W ),
    .CLK_VAL   (CLK_VAL   )
  ) cu (
    .clk_i          (clk_i            ),
    .reset_i        (reset_i          ),
    .m_axis_tvalid_o(axis_tvalid[0]   ),
    .m_axis_tready_i(axis_tready[0]   ),
    .m_axis_tlast_o (axis_tlast[0]    ),
    .m_axis_tdata_o (axis_tdata[0]    ),
    .s_axis_tvalid_i(axis_tvalid[N_EU]),
    .s_axis_tready_o(axis_tready[N_EU]),
    .s_axis_tlast_i (axis_tlast[N_EU] ),
    .s_axis_tdata_i (axis_tdata[N_EU] )
  );

  genvar j;
  generate for (j = 0; j < N_EU; j++) begin
    eu_controller #(
      .AXIS_DIN_W(AXIS_DIN_W),
      .CMD_W     (CMD_W     ),
      .ID        (EU_ID[j]  ),
      .ID_W      (ID_W      )
    ) eu (
      .clk_i(clk_i),
      .reset_i        (reset_i         ),
      .s_axis_tvalid_i(axis_tvalid[j]  ),
      .s_axis_tready_o(axis_tready[j]  ),
      .s_axis_tlast_i (axis_tlast[j]   ),
      .s_axis_tdata_i (axis_tdata[j]   ),
      .m_axis_tvalid_o(axis_tvalid[j+1]),
      .m_axis_tready_i(axis_tready[j+1]),
      .m_axis_tlast_o (axis_tlast[j+1] ),
      .m_axis_tdata_o (axis_tdata[j+1] )
    );
  end endgenerate

endmodule

`default_nettype wire