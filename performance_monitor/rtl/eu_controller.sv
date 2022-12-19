`default_nettype none

module eu_controller #(
  parameter AXIS_DIN_W = 8,
  parameter CMD_W      = 3000,
  parameter ID         = 8'b00000001,
  parameter ID_W       = 8
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
  output logic [AXIS_DIN_W-1:0]m_axis_tdata_o
);

  localparam CMD_SEND_ = 8'b00010001;
  localparam CMD_WR_   = 8'b00000001;

  typedef enum {
    WAIT_DATA,
    GET_DATA,
    SEND_NEXT,
    CMD_WR,
    SEND_AND_WR,
    CMD_SEND,
    SEND_AND_SEND
  } eu_fsm_state_enum;

  eu_fsm_state_enum state;
  eu_fsm_state_enum next_state;

  logic  [ID_W-1:0]self_id      = ID;
  logic  [ID_W-1:0]broadcast_id = {ID_W{1'b1}};

  logic [CMD_W-1:0]cmd_in_ff;
  logic [CMD_W-1:0]cmd_out_ff;
  logic [CMD_W-1:0]cmd_send_ff = {{CMD_W-ID_W{1'b1}}, ID};

  logic s_tready_ff;
  logic m_tvalid_ff;

  assign s_axis_tready_o = s_tready_ff;
  assign m_axis_tvalid_o = m_tvalid_ff;
  assign m_axis_tdata_o  = cmd_out_ff;

  logic s_handshake;
  logic m_handshake;
  logic cmd_wr_self;
  logic cmd_wr_broadcast;
  logic cmd_not_self;
  logic cmd_send_self;
  logic cmd_send_broadcast;

  logic data_valid;
  logic cmd_broadcast;
  logic cmd_self;
  logic cmd_wr;
  logic cmd_send;

  always_comb begin
    data_valid    = (state == GET_DATA);
    cmd_self      = (cmd_in_ff[ID_W-1:0] == self_id);
    cmd_broadcast = (cmd_in_ff[ID_W-1:0] == broadcast_id);
    cmd_wr        = (cmd_in_ff[2*ID_W-1:ID_W] == CMD_WR_);
    cmd_send      = (cmd_in_ff[2*ID_W-1:ID_W] == CMD_SEND_);

    s_handshake        = s_axis_tvalid_i && s_axis_tready_o;
    m_handshake        = m_axis_tvalid_o && m_axis_tready_i;
    cmd_wr_self        = data_valid && cmd_self && cmd_wr;
    cmd_wr_broadcast   = data_valid && cmd_broadcast && cmd_wr;
    cmd_send_self      = data_valid && cmd_self && cmd_send;
    cmd_send_broadcast = data_valid && cmd_broadcast && cmd_send;
    cmd_not_self       = data_valid && ~cmd_self && ~cmd_broadcast;
  end

  always_comb begin
    casez (state)
      WAIT_DATA: begin
        next_state = s_handshake ? GET_DATA : WAIT_DATA;
      end
      GET_DATA: begin
        next_state = cmd_not_self        ? SEND_NEXT     :
                      cmd_wr_self        ? CMD_WR        :
                      cmd_wr_broadcast   ? SEND_AND_WR   :
                      cmd_send_self      ? CMD_SEND      :
                      cmd_send_broadcast ? SEND_AND_SEND : WAIT_DATA;
      end
      SEND_NEXT: begin
        next_state = m_handshake ? WAIT_DATA : SEND_NEXT;
      end
      CMD_WR: begin
        next_state = s_handshake ? GET_DATA : WAIT_DATA;
      end
      SEND_AND_WR: begin
        next_state = m_handshake ? WAIT_DATA : SEND_NEXT;
      end
      CMD_SEND: begin
        next_state = m_handshake ? WAIT_DATA : SEND_NEXT;
      end
      SEND_AND_SEND: begin
        next_state = m_handshake ? SEND_NEXT : SEND_AND_SEND;
      end
      default: begin
        next_state = WAIT_DATA;
      end
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
      cmd_in_ff <= {CMD_W{1'b0}};
    end else begin
      cmd_in_ff <= (next_state == GET_DATA) ? s_axis_tdata_i : cmd_in_ff;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      s_tready_ff <= 1'b1;
    end else begin
      s_tready_ff <= (next_state == WAIT_DATA) || (next_state == CMD_WR);
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      m_tvalid_ff <= 1'b0;
    end else begin
      m_tvalid_ff <= ~((next_state == WAIT_DATA) || (next_state == CMD_WR) || (next_state == GET_DATA));
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cmd_out_ff <= {CMD_W{1'b0}};
    end else begin
      cmd_out_ff <= ((state == GET_DATA) && (next_state != CMD_WR)) ? cmd_in_ff :
                    ((state == SEND_AND_SEND) && (next_state == SEND_NEXT)) ? cmd_send_ff : cmd_out_ff;
    end
  end

endmodule

`default_nettype wire
