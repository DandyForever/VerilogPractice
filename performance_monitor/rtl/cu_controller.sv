`default_nettype none

module cu_controller #(
  parameter AXIS_DIN_W = 8,
  parameter CMD_W      = 3000,
  parameter ID         = 8'b00000000,
  parameter ID_W       = 8,
  parameter N_EU       = 8'b0000_0011,
  parameter CLK_CNT_W  = 32,
  parameter CLK_VAL    = 32'h0000_1000
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

  localparam CMD_SEND_   = 8'b00010001;
  localparam CMD_WR_     = 8'b00000001;
  localparam BC_CMD_WR   = {{CMD_W-16{1'b1}}, CMD_WR_, 8'hFF};
  localparam BC_CMD_SEND = {{CMD_W-16{1'b1}}, CMD_SEND_, 8'hFF};
  localparam N_GET       = N_EU + 2'd2;

  typedef enum {
    WAIT_CLK,
    BC_WR,
    BC_SEND,
    WAIT_EU
  } cu_fsm_state_enum;

  cu_fsm_state_enum state;
  cu_fsm_state_enum next_state;

  logic m_tvalid_ff;
  logic s_tready_ff;
  logic [CMD_W-1:0]cmd_out_ff;
  logic [CMD_W-1:0]cmd_in_ff;

  assign m_axis_tdata_o  = cmd_out_ff;
  assign s_axis_tready_o = s_tready_ff;
  assign m_axis_tvalid_o = m_tvalid_ff;

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

  logic m_handshake;
  logic s_handshake;
  logic [ID_W-1:0]s_hs_cnt;
  logic get_all_eu;

  assign s_handshake = s_axis_tvalid_i && s_axis_tready_o;
  assign m_handshake = m_axis_tvalid_o && m_axis_tready_i;
  assign get_all_eu  = (s_hs_cnt == N_GET);

  always_comb begin
    casez (state)
      WAIT_CLK: begin
        next_state = clk_counted ? BC_WR : WAIT_CLK;
      end
      BC_WR: begin
        next_state = m_handshake ? BC_SEND : BC_WR;
      end
      BC_SEND: begin
        next_state = m_handshake ? WAIT_EU : BC_SEND;
      end
      WAIT_EU: begin
        next_state = get_all_eu ? WAIT_CLK : WAIT_EU;
      end
      default: begin
        next_state = WAIT_CLK;
      end
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
      s_hs_cnt <= {ID_W{1'b0}};
    end else begin
      s_hs_cnt <= get_all_eu ? {ID_W{1'b0}} : s_hs_cnt + s_handshake;
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
      cmd_out_ff <= {CMD_W{1'b0}};
    end else begin
      cmd_out_ff <= (next_state == BC_WR  ) ? BC_CMD_WR :
                    (next_state == BC_SEND) ? BC_CMD_SEND : cmd_out_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_in_ff <= {CMD_W{1'b0}};
    end else begin
      cmd_in_ff <= s_handshake ? s_axis_tdata_i : cmd_in_ff;
    end
  end

endmodule

`default_nettype wire
