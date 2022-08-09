`include "bli201v32itl_tl_defines.vh"

module tl2reg_adapter (
  input  clk,
  input  rst,
  
  input  [`TL_A_WIDTH_OPCODE-1:0]   adapter_i_tl_a_opcode,
  input  [`TL_A_WIDTH_PARAM-1:0]    adapter_i_tl_a_param,
  input  [`TL_A_WIDTH_SIZE-1:0]     adapter_i_tl_a_size,
  input  [`TL_A_WIDTH_SOURCE-1:0]   adapter_i_tl_a_source,
  input  [`TL_A_WIDTH_ADDRESS-1:0]  adapter_i_tl_a_address,
  input  [`TL_A_WIDTH_MASK-1:0]     adapter_i_tl_a_mask,
  input  [`TL_A_WIDTH_DATA-1:0]     adapter_i_tl_a_data,
  input  [`TL_A_WIDTH_CORRUPT-1:0]  adapter_i_tl_a_corrupt,
  input                             adapter_i_tl_a_valid,
  output                            adapter_o_tl_a_ready,
  
  output [`TL_D_WIDTH_OPCODE-1:0]   adapter_o_tl_d_opcode,
  output [`TL_D_WIDTH_PARAM-1:0]    adapter_o_tl_d_param,
  output [`TL_D_WIDTH_SIZE-1:0]     adapter_o_tl_d_size,
  output [`TL_D_WIDTH_SOURCE-1:0]   adapter_o_tl_d_source,
  output [`TL_D_WIDTH_SINK-1:0]     adapter_o_tl_d_sink,
  output [`TL_D_WIDTH_DENIED-1:0]   adapter_o_tl_d_denied,
  output [`TL_D_WIDTH_DATA-1:0]     adapter_o_tl_d_data,
  output [`TL_D_WIDTH_CORRUPT-1:0]  adapter_o_tl_d_corrupt,
  output                            adapter_o_tl_d_valid,
  input                             adapter_i_tl_d_ready,
  
  // register interface
  output [`TL_A_WIDTH_ADDRESS-1:0] adapter_o_address,
  output adapter_o_r_en,
  output adapter_o_w_en,
  output [`TL_A_WIDTH_MASK-1:0] adapter_o_wmask,
  output [`TL_A_WIDTH_DATA-1:0] adapter_o_wdata,
  input  [`TL_A_WIDTH_DATA-1:0] adapter_i_rdata,
  input  adapter_i_err
);

  wire tl_a_accept;
  wire tl_d_accept;

  reg [31:0] tl_d_data_reg;
  reg tl_d_denied_reg;

  wire err_internal;
  wire addr_align_err;
  wire tl_err;

  reg [`TL_D_WIDTH_SOURCE-1:0] tl_d_source_reg;
  reg [`TL_A_WIDTH_SIZE-1:0] tl_d_size_reg;
  reg [`TL_D_WIDTH_OPCODE-1:0] tl_d_opcode_reg;
  reg [`TL_D_WIDTH_PARAM-1:0] tl_d_param_reg;
  

  wire is_get_request;
  wire is_put_request;

  reg tl_d_inflight_reg;

  assign tl_a_accept = adapter_i_tl_a_valid && adapter_o_tl_a_ready;
  assign tl_d_accept = adapter_o_tl_d_valid && adapter_i_tl_d_ready;

  // Request signals coming from Host
  assign is_get_request = tl_a_accept && (adapter_i_tl_a_opcode === `TL_A_MSG_GET_OPCODE);
  assign is_put_request = tl_a_accept && ((adapter_i_tl_a_opcode === `TL_A_MSG_PUTFULLDATA_OPCODE) || (adapter_i_tl_a_opcode === `TL_A_MSG_PUTPARTIALDATA_OPCODE));

  assign adapter_o_address = adapter_i_tl_a_address;
  assign adapter_o_r_en = is_get_request && !err_internal;
  assign adapter_o_w_en = is_put_request && !err_internal;
  assign adapter_o_wmask = adapter_i_tl_a_mask;
  assign adapter_o_wdata = adapter_i_tl_a_data;


  assign addr_align_err = is_put_request && (adapter_i_tl_a_address[1:0] != 'b00);
  assign tl_err = 'b0;  // TODO
  assign err_internal = addr_align_err | tl_err;

  assign adapter_o_tl_a_ready = !tl_d_inflight_reg;
  assign adapter_o_tl_d_valid = tl_d_inflight_reg;
  assign adapter_o_tl_d_opcode = tl_d_opcode_reg;
  assign adapter_o_tl_d_param = tl_d_param_reg;
  assign adapter_o_tl_d_size = tl_d_size_reg;
  assign adapter_o_tl_d_source = tl_d_source_reg;
  assign adapter_o_tl_d_sink = 'b0;
  assign adapter_o_tl_d_data = tl_d_data_reg;
  assign adapter_o_tl_d_corrupt = 'b0;
  assign adapter_o_tl_d_denied = tl_d_denied_reg;

  always @(posedge clk) begin
    if (!rst) begin
      tl_d_inflight_reg <= 'b0;

      tl_d_opcode_reg <= `TL_D_MSG_ACCESSACK_OPCODE;
      tl_d_param_reg <= `TL_D_MSG_ACCESSACK_PARAM;
      tl_d_size_reg <= 'h0;
      tl_d_source_reg <= 'h0;
    end
    else begin
      if (tl_a_accept) begin
        tl_d_inflight_reg <= 'b1;

        tl_d_opcode_reg <= is_get_request ? `TL_D_MSG_ACCESSACKDATA_OPCODE : `TL_D_MSG_ACCESSACK_OPCODE;
        tl_d_param_reg <= is_get_request ? `TL_D_MSG_ACCESSACKDATA_PARAM : `TL_D_MSG_ACCESSACK_PARAM;
        tl_d_size_reg <= adapter_i_tl_a_size;
        tl_d_source_reg <= adapter_i_tl_a_source;
        tl_d_data_reg <= err_internal ? 'hEEEEEEEE : adapter_i_rdata;
        tl_d_denied_reg <= adapter_i_err || err_internal;
      end
      else if (tl_d_accept) begin
        tl_d_inflight_reg <= 'b0;
      end
    end
  end

endmodule