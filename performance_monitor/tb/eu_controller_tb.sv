module eu_controller_tb();
  localparam AXIS_DIN_W = 24;
  localparam CMD_W      = 24;
  localparam ID_W       = 8;

  logic clk, reset;

  logic s_axis_tvalid, s_axis_tready, s_axis_tlast;
  logic m_axis_tvalid, m_axis_tready, m_axis_tlast;

  logic [AXIS_DIN_W-1:0]s_axis_tdata;
  logic [AXIS_DIN_W-1:0]m_axis_tdata;

  eu_controller #(
    .AXIS_DIN_W(AXIS_DIN_W),
    .CMD_W     (CMD_W),
    .ID        (8'b00000001),
    .ID_W      (ID_W)
  ) dut (
    .clk_i          (clk          ),
    .reset_i        (reset        ),
    .s_axis_tvalid_i(s_axis_tvalid),
    .s_axis_tready_o(s_axis_tready),
    .s_axis_tlast_i (s_axis_tlast ),
    .s_axis_tdata_i (s_axis_tdata ),
    .m_axis_tvalid_o(m_axis_tvalid),
    .m_axis_tready_i(m_axis_tready),
    .m_axis_tlast_o (m_axis_tlast ),
    .m_axis_tdata_o (m_axis_tdata )
  );

  always begin
    clk = 1'b0; #1;
    clk = 1'b1; #1;
  end

  initial begin
    s_axis_tlast = 1'b0;
    m_axis_tready = 1'b1;
    reset = 1'b1; #1.5;
    reset = 1'b0;
    s_axis_tdata = {{CMD_W-16{1'b1}}, 8'b1, 8'b1};
    s_axis_tvalid = 1'b1; #2; s_axis_tvalid = 1'b0; #1;
    s_axis_tdata = {{CMD_W-16{1'b1}}, 8'b1_0001, 8'b1};
    s_axis_tvalid = 1'b1; #10;
    $finish;
  end


endmodule