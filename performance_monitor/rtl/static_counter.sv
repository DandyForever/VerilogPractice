`default_nettype none

module static_counter #(
  parameter CNT_W = 16
)(
  input logic clk_i,
  input logic reset_i,

  input logic signal_i,

  input logic cmd_we_i,
  input logic en_i,
  input logic clear_i,
  input logic save_i,

  output logic [CNT_W-1:0]cnt_val_o,
  output logic            ovf_o
);

  logic [CNT_W-1:0]cnt_ff;
  logic [CNT_W-1:0]cnt_reg_ff;
  logic            en_ff;
  logic            ovf_ff;

  assign cnt_val_o = cnt_reg_ff;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      en_ff <= 1'b0;
    end else begin
      en_ff <= cmd_we_i ? en_i : en_ff;
    end
  end

  logic is_clear;
  logic is_incr;
  assign is_clear = cmd_we_i && clear_i;
  assign is_incr  = en_ff && signal_i;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cnt_ff <= {CNT_W{1'b0}};
    end else begin
      if (is_clear) begin
        cnt_ff <= {CNT_W{1'b0}};
      end else begin
        cnt_ff <= is_incr ? cnt_ff + 1'b1 : cnt_ff;
      end
    end
  end

  logic is_save;
  assign is_save = cmd_we_i && save_i;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      cnt_reg_ff <= {CNT_W{1'b0}};
    end else begin
      cnt_reg_ff <= is_save ? cnt_ff : cnt_reg_ff;
    end
  end

  logic is_ovf;
  assign is_ovf = &cnt_ff;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      ovf_ff <= 1'b0;
    end else begin
      ovf_ff <= is_clear ? 1'b0 : is_ovf ? 1'b1 : 1'b0;
    end
  end

endmodule

`default_nettype wire
