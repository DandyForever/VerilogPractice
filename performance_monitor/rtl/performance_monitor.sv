`default_nettype none

module performance_monitor #(
  parameter AXIS_DIN_W = 8,
  parameter N_EU       = 8'd3,
  parameter ID_W       = 8,
  parameter CU_ID      = 8'b0,
  parameter [ID_W-1:0]EU_ID[N_EU-1:0] = {8'd1, 8'd2, 8'd3},
  parameter CLK_CNT_W  = 32,
  parameter CLK_VAL    = 32'h1000,
  parameter BUF_S      = 128,
  parameter CNT_W      = 16,
  parameter CC_N       = 6,
  parameter SC_N       = 4
)(
  input logic clk_i,
  input logic reset_i,

  input logic [N_EU-1:0][SC_N-1:0]signal_i,

  input logic [N_EU-1:0][CC_N-1:0]axis_tvalid_i,
  input logic [N_EU-1:0][CC_N-1:0]axis_tready_i,
  input logic [N_EU-1:0][CC_N-1:0]axis_tlast_i
);

  logic                 axis_tvalid[N_EU:0];
  logic                 axis_tready[N_EU:0];
  logic                 axis_tlast [N_EU:0];
  logic [AXIS_DIN_W-1:0]axis_tdata [N_EU:0];

  cu_controller #(
    .AXIS_DIN_W(AXIS_DIN_W),
    .ID        (CU_ID     ),
    .ID_W      (ID_W      ),
    .N_EU      (N_EU      ),
    .CLK_CNT_W (CLK_CNT_W ),
    .CLK_VAL   (CLK_VAL   ),
    .BUF_S     (BUF_S     )
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
      .ID        (EU_ID[j]  ),
      .ID_W      (ID_W      ),
      .BUF_S     (BUF_S     ),
      .CNT_W     (CNT_W     ),
      .CC_N      (CC_N      ),
      .SC_N      (SC_N      )
    ) eu (
      .clk_i          (clk_i           ),
      .reset_i        (reset_i         ),
      .s_axis_tvalid_i(axis_tvalid[j]  ),
      .s_axis_tready_o(axis_tready[j]  ),
      .s_axis_tlast_i (axis_tlast[j]   ),
      .s_axis_tdata_i (axis_tdata[j]   ),
      .m_axis_tvalid_o(axis_tvalid[j+1]),
      .m_axis_tready_i(axis_tready[j+1]),
      .m_axis_tlast_o (axis_tlast[j+1] ),
      .m_axis_tdata_o (axis_tdata[j+1] ),
      .signal_i       (signal_i[j]     ),
      .axis_tvalid_i  (axis_tvalid_i[j]),
      .axis_tready_i  (axis_tready_i[j]),
      .axis_tlast_i   (axis_tlast_i[j] )
    );
  end endgenerate

endmodule

`default_nettype wire
