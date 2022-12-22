`default_nettype none

module cu_controller #(
  parameter AXIS_DIN_W = 8,
  parameter CMD_W      = 3000,
  parameter ID         = 8'b0,
  parameter ID_W       = 8,
  parameter N_EU       = 8'b11,
  parameter CLK_CNT_W  = 32,
  parameter CLK_VAL    = 32'h1000,
  parameter BUF_S      = 128,
  parameter ADDR_W     = $clog2(BUF_S)
)(
  input logic clk_i,
  input logic reset_i,

  output logic                 m_axis_tvalid_o,
  input  logic                 m_axis_tready_i,
  output logic                 m_axis_tlast_o,
  output logic [AXIS_DIN_W-1:0]m_axis_tdata_o,

  input  logic                 s_axis_tvalid_i,
  output logic                 s_axis_tready_o,
  input  logic                 s_axis_tlast_i,
  input  logic [AXIS_DIN_W-1:0]s_axis_tdata_i
);

  localparam CMD_SEND_     = 8'b00010001;
  localparam CMD_WR_       = 8'b00000001;
  localparam BC_CMD_WR     = {8'hAA, CMD_WR_, 8'hFF};
  localparam BC_CMD_SEND   = {CMD_SEND_, 8'hFF};
  localparam N_GET         = N_EU + 2'd2;
  localparam CMD_WR_SIZE   = 7'b11;
  localparam CMD_SEND_SIZE = 7'b10;

  typedef enum {
    WAIT_CLK,
    BC_WR,
    WAIT_RESP,
    BC_SEND,
    WAIT_EU
  } cu_fsm_state_enum;

  cu_fsm_state_enum state;
  cu_fsm_state_enum next_state;

  logic m_tvalid_ff;
  logic m_tlast_ff;
  logic s_tready_ff;
  logic [BUF_S-1:0][AXIS_DIN_W-1:0]cmd_out_ff;
  logic            [AXIS_DIN_W-1:0]cmd_in_ff;
  logic [ADDR_W-1:0]cmd_out_addr_ff;
  logic [ADDR_W-1:0]size_to_send_ff;

  assign m_axis_tdata_o  = cmd_out_ff[cmd_out_addr_ff];
  assign s_axis_tready_o = s_tready_ff;
  assign m_axis_tvalid_o = m_tvalid_ff;
  assign m_axis_tlast_o  = m_tlast_ff;

  logic [CLK_CNT_W-1:0]clk_cnt_ff;
  logic clk_counted;

  assign clk_counted = (clk_cnt_ff == CLK_VAL);

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      clk_cnt_ff <= {CLK_CNT_W{1'b0}};
    end else begin
      clk_cnt_ff <= clk_counted ? {CLK_CNT_W{1'b0}} : clk_cnt_ff + 1'b1;
    end
  end

  logic m_hs;
  logic s_hs;
  logic m_hs_tlast;
  logic s_hs_tlast;
  logic [ID_W-1:0]s_hs_tlast_cnt;
  logic get_all_eu;

  assign s_hs       = s_axis_tvalid_i && s_axis_tready_o;
  assign m_hs       = m_axis_tvalid_o && m_axis_tready_i;
  assign s_hs_tlast = s_hs && s_axis_tlast_i;
  assign m_hs_tlast = m_hs && m_axis_tlast_o;
  assign get_all_eu = (s_hs_tlast_cnt == N_GET);

  always_comb begin
    casez (state)
      WAIT_CLK : next_state = clk_counted ? BC_WR     : WAIT_CLK;
      BC_WR    : next_state = m_hs_tlast  ? WAIT_RESP : BC_WR;
      WAIT_RESP: next_state = s_hs_tlast  ? BC_SEND   : WAIT_RESP;
      BC_SEND  : next_state = m_hs_tlast  ? WAIT_EU   : BC_SEND;
      WAIT_EU  : next_state = get_all_eu  ? WAIT_CLK  : WAIT_EU;
      default  : next_state = WAIT_CLK;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      state <= WAIT_CLK;
    end else begin
      state <= next_state;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      s_hs_tlast_cnt <= {ID_W{1'b0}};
    end else begin
      s_hs_tlast_cnt <= get_all_eu ? {ID_W{1'b0}} : s_hs_tlast_cnt + s_hs_tlast;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      m_tvalid_ff <= 1'b0;
    end else begin
      m_tvalid_ff <= (next_state == BC_WR) || (next_state == BC_SEND);
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      s_tready_ff <= 1'b0;
    end else begin
      s_tready_ff <= ~(next_state == WAIT_CLK);
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_out_ff <= 0;
    end else begin
      cmd_out_ff <= (next_state == BC_WR  ) ? BC_CMD_WR :
                    (next_state == BC_SEND) ? BC_CMD_SEND : cmd_out_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_out_addr_ff <= {ADDR_W{1'b0}};
    end else begin
      cmd_out_addr_ff <= m_hs_tlast ? {ADDR_W{1'b0}} : m_hs ? cmd_out_addr_ff + 1 : cmd_out_addr_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_in_ff <= 0;
    end else begin
      cmd_in_ff <= s_hs ? s_axis_tdata_i : cmd_in_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      size_to_send_ff <= {ADDR_W{1'b0}};
    end else begin
      size_to_send_ff <= (next_state == BC_WR) ? CMD_WR_SIZE :
                          (next_state == BC_SEND) ? CMD_SEND_SIZE : size_to_send_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      m_tlast_ff <= 1'b0;
    end else begin
      m_tlast_ff <= (cmd_out_addr_ff + 2 == size_to_send_ff) && m_axis_tvalid_o;
    end
  end

  always @(posedge clk_i) begin
    if (state == WAIT_EU && next_state == WAIT_CLK) begin
      $display("Latency %d", clk_cnt_ff);
    end
  end

endmodule

`default_nettype wire
