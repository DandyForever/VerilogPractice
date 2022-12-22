`default_nettype none

module eu_controller #(
  parameter AXIS_DIN_W = 8,
  parameter ID         = 8'b1,
  parameter ID_W       = 8,
  parameter BUF_S      = 128,
  parameter ADDR_W     = $clog2(BUF_S),
  parameter CNT_W      = 16,
  parameter CC_N       = 6,
  parameter SC_N       = 4
)(
  input logic clk_i,
  input logic reset_i,

  input  logic                 s_axis_tvalid_i,
  output logic                 s_axis_tready_o,
  input  logic                 s_axis_tlast_i,
  input  logic [AXIS_DIN_W-1:0]s_axis_tdata_i,

  output logic                 m_axis_tvalid_o,
  input  logic                 m_axis_tready_i,
  output logic                 m_axis_tlast_o,
  output logic [AXIS_DIN_W-1:0]m_axis_tdata_o,

  input logic [SC_N-1:0]signal_i,

  input logic [CC_N-1:0]axis_tvalid_i,
  input logic [CC_N-1:0]axis_tready_i,
  input logic [CC_N-1:0]axis_tlast_i
);

  localparam CMD_SEND_ = 8'b00010001;
  localparam CMD_WR_   = 8'b00000001;
  localparam BC_ID     = {ID_W{1'b1}};
  localparam CNT_N     = SC_N + CC_N;
  localparam BUF_EL_FOR_CNT = CNT_W / AXIS_DIN_W;
  localparam DATA_N    = CNT_N*BUF_EL_FOR_CNT+1;

  typedef enum {
    WAIT_DATA,
    GET_DATA,
    SEND_CMD_RECV_CMD,
    SEND_CMD,
    SELF_CMD_WR,
    SELF_CMD_SEND,
    BC_CMD_WR,
    BC_CMD_SEND,
    SEND_CMD_SEND_DATA
  } eu_fsm_state_enum;

  eu_fsm_state_enum state;
  eu_fsm_state_enum next_state;

  logic [BUF_S-1:0][AXIS_DIN_W-1:0]cmd_in_ff;
  logic [BUF_S-1:0][AXIS_DIN_W-1:0]cmd_out_ff;
  logic [BUF_S-1:0][AXIS_DIN_W-1:0]cmd_send_data;

  logic [ADDR_W-1:0]cmd_in_addr_ff;
  logic [ADDR_W-1:0]cmd_out_addr_ff;

  logic [ADDR_W-1:0]recv_size_ff;
  logic [ADDR_W-1:0]size_to_send_ff;

  logic [ID_W-1:0]conf_reg_ff;
  logic           cmd_we_ff;

  logic s_tready_ff;
  logic m_tvalid_ff;
  logic m_tlast_ff;

  always_comb begin
    s_axis_tready_o = s_tready_ff;
    m_axis_tvalid_o = m_tvalid_ff;
    m_axis_tlast_o  = m_tlast_ff;
    m_axis_tdata_o  = cmd_out_ff[cmd_out_addr_ff];
  end

  logic s_hs;
  logic s_hs_tlast;
  logic m_hs;
  logic m_hs_tlast;
  logic hs_tlast;
  logic self_cmd;
  logic bc_cmd;
  logic nself_cmd;
  logic cmd_wr;
  logic cmd_send;
  logic self_cmd_wr;
  logic self_cmd_send;
  logic bc_cmd_wr;
  logic bc_cmd_send;

  always_comb begin
    s_hs          = s_axis_tvalid_i && s_axis_tready_o;
    s_hs_tlast    = s_hs && s_axis_tlast_i;
    m_hs          = m_axis_tvalid_o && m_axis_tready_i;
    m_hs_tlast    = m_hs && m_axis_tlast_o;
    hs_tlast      = s_hs_tlast && m_hs_tlast;
    self_cmd      = (cmd_in_ff[0] == ID);
    bc_cmd        = (cmd_in_ff[0] == BC_ID);
    nself_cmd     = ~(self_cmd || bc_cmd);
    cmd_wr        = (cmd_in_ff[1] == CMD_WR_);
    cmd_send      = (cmd_in_ff[1] == CMD_SEND_);
    self_cmd_wr   = self_cmd && cmd_wr;
    self_cmd_send = self_cmd && cmd_send;
    bc_cmd_wr     = bc_cmd   && cmd_wr;
    bc_cmd_send   = bc_cmd   && cmd_send;
  end

  always_comb begin
    casez (state)
      WAIT_DATA         : next_state = s_hs_tlast     ? GET_DATA           : WAIT_DATA;
      GET_DATA          : next_state = nself_cmd      ? SEND_CMD_RECV_CMD  :
                                        self_cmd_wr   ? SELF_CMD_WR        :
                                        self_cmd_send ? SELF_CMD_SEND      :
                                        bc_cmd_wr     ? BC_CMD_WR          :
                                        bc_cmd_send   ? BC_CMD_SEND        : WAIT_DATA;
      SEND_CMD_RECV_CMD : next_state = hs_tlast       ? GET_DATA           :
                                        s_hs_tlast    ? SEND_CMD           :
                                        m_hs_tlast    ? WAIT_DATA          : SEND_CMD_RECV_CMD;
      SEND_CMD          : next_state = m_hs_tlast     ? GET_DATA           : SEND_CMD;
      SELF_CMD_WR       : next_state = s_hs_tlast     ? GET_DATA           : WAIT_DATA;
      SELF_CMD_SEND     : next_state = s_hs_tlast     ? SEND_CMD           : SEND_CMD_RECV_CMD;
      BC_CMD_WR         : next_state = s_hs_tlast     ? SEND_CMD           : SEND_CMD_RECV_CMD;
      BC_CMD_SEND       : next_state = hs_tlast       ? SEND_CMD           :
                                        s_hs_tlast    ? SEND_CMD_SEND_DATA :
                                        m_hs_tlast    ? SEND_CMD_RECV_CMD  : BC_CMD_SEND;
      SEND_CMD_SEND_DATA: next_state = m_hs_tlast     ? SEND_CMD           : SEND_CMD_SEND_DATA;
      default           : next_state = WAIT_DATA;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= WAIT_DATA;
    end else begin
      state <= next_state;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_in_ff <= 0;
    end else begin
      cmd_in_ff[cmd_in_addr_ff] <= s_hs ? s_axis_tdata_i : cmd_in_ff[cmd_in_addr_ff];
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      s_tready_ff <= 1'b1;
    end else begin
      s_tready_ff <= ~((next_state == SEND_CMD_SEND_DATA) || (next_state == SEND_CMD));
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      m_tvalid_ff <= 1'b0;
    end else begin
      m_tvalid_ff <= ~((next_state == WAIT_DATA) || (next_state == GET_DATA) || (next_state == SELF_CMD_WR));
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_in_addr_ff <= {ADDR_W{1'b0}};
    end else begin
      cmd_in_addr_ff <= s_hs_tlast ? {ADDR_W{1'b0}} : s_hs ? cmd_in_addr_ff + 1 : cmd_in_addr_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_out_addr_ff <= {ADDR_W{1'b0}};
    end else begin
      cmd_out_addr_ff <= m_hs_tlast ? {ADDR_W{1'b0}} : m_hs ? cmd_out_addr_ff + 1 : cmd_out_addr_ff;
    end
  end

  logic cmd_to_send;
  logic data_to_send;

  assign cmd_to_send = (state == GET_DATA) && ((next_state == SEND_CMD_RECV_CMD) ||
                       (next_state == BC_CMD_WR) || (next_state == BC_CMD_SEND));
  assign data_to_send = (state == GET_DATA) && (next_state == SELF_CMD_SEND) ||
                        (state == BC_CMD_SEND) && (next_state != SEND_CMD_SEND_DATA) && (next_state != BC_CMD_SEND) ||
                        (state == SEND_CMD_SEND_DATA) && (next_state == SEND_CMD);

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_out_ff <= 0;
    end else begin
      cmd_out_ff <= cmd_to_send ? cmd_in_ff : data_to_send ? cmd_send_data : cmd_out_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      recv_size_ff <= {ADDR_W{1'b0}};
    end else begin
      recv_size_ff <= s_hs_tlast ? cmd_in_addr_ff : recv_size_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      size_to_send_ff <= {ADDR_W{1'b0}};
    end else begin
      size_to_send_ff <= cmd_to_send ? recv_size_ff : data_to_send ? DATA_N : size_to_send_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      m_tlast_ff <= 1'b0;
    end else begin
      m_tlast_ff <= (cmd_out_addr_ff + 1 == size_to_send_ff);
    end
  end

  logic write_reg;

  assign write_reg = (state == GET_DATA) && ((next_state == SELF_CMD_WR) || (next_state == BC_CMD_WR));

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      conf_reg_ff <= {ID_W{1'b0}};
    end else begin
      conf_reg_ff <= write_reg ? cmd_in_ff[2] : conf_reg_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_we_ff <= 1'b0;
    end else begin
      cmd_we_ff <= write_reg;
    end
  end

  logic [CNT_N-1:0][CNT_W-1:0]cnt_val;
  logic [CNT_N-1:0]           ovf;

  assign cmd_send_data[0] = {ID_W{1'b0}};
  assign cmd_send_data[1] = ID;

  genvar j, k;

  for (j = 0; j < CNT_N; j++) begin
    for (k = 0; k < BUF_EL_FOR_CNT; k++) begin
      assign cmd_send_data[BUF_EL_FOR_CNT*j+k+2] = cnt_val[j][k*AXIS_DIN_W +:AXIS_DIN_W];
    end
  end

  for (j = BUF_EL_FOR_CNT*CNT_N+1; j < BUF_S; j++) begin
    assign cmd_send_data[j] = {AXIS_DIN_W{1'b0}};
  end

  perf_counters #(
    .CNT_W(CNT_W),
    .CC_N (CC_N),
    .SC_N (SC_N)
  ) eu_counters (
    .clk_i        (clk_i           ),
    .reset_i      (reset_i         ),
    .signal_i     (signal_i        ),
    .axis_tvalid_i(axis_tvalid_i   ),
    .axis_tready_i(axis_tready_i   ),
    .axis_tlast_i (axis_tlast_i    ),
    .cmd_we_i     (cmd_we_ff       ),
    .en_i         (conf_reg_ff[0]  ),
    .clear_i      (conf_reg_ff[1]  ),
    .save_i       (conf_reg_ff[2]  ),
    .mode_i       (conf_reg_ff[4:3]),
    .cnt_val_o    (cnt_val         ),
    .ovf_o        (ovf             )
  );

endmodule

`default_nettype wire
