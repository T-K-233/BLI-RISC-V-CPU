`include "bli201v32itl_tl_defines.vh"

module biu (
  input  clk,
  input  rst,
  
  output        biu_o_halt,

  input  [31:0] biu_i_iaddr,
  output [31:0] biu_o_idata,

  input  [31:0] biu_i_daddr,
  input         biu_i_is_load,
  input         biu_i_is_store,
  input  [3:0]  biu_i_dwmask,
  input  [31:0] biu_i_dwdata,
  output [31:0] biu_o_drdata,

  output [11:0] biu_o_itim_addr,
  input  [31:0] biu_i_itim_rdata,

  output [11:0] biu_o_dtim_addr,
  output [3:0]  biu_o_dtim_wmask,
  output [31:0] biu_o_dtim_wdata,
  input  [31:0] biu_i_dtim_rdata,
  
  output [`TL_A_WIDTH_OPCODE-1:0]   biu_o_tl_a_opcode,
  output [`TL_A_WIDTH_PARAM-1:0]    biu_o_tl_a_param,
  output [`TL_A_WIDTH_SIZE-1:0]     biu_o_tl_a_size,
  output [`TL_A_WIDTH_SOURCE-1:0]   biu_o_tl_a_source,
  output [`TL_A_WIDTH_ADDRESS-1:0]  biu_o_tl_a_address,
  output [`TL_A_WIDTH_MASK-1:0]     biu_o_tl_a_mask,
  output [`TL_A_WIDTH_DATA-1:0]     biu_o_tl_a_data,
  output [`TL_A_WIDTH_CORRUPT-1:0]  biu_o_tl_a_corrupt,
  output                            biu_o_tl_a_valid,
  input                             biu_i_tl_a_ready,
  
  input  [`TL_D_WIDTH_OPCODE-1:0]   biu_i_tl_d_opcode,
  input  [`TL_D_WIDTH_PARAM-1:0]    biu_i_tl_d_param,
  input  [`TL_D_WIDTH_SIZE-1:0]     biu_i_tl_d_size,
  input  [`TL_D_WIDTH_SOURCE-1:0]   biu_i_tl_d_source,
  input  [`TL_D_WIDTH_SINK-1:0]     biu_i_tl_d_sink,
  input  [`TL_D_WIDTH_DENIED-1:0]   biu_i_tl_d_denied,
  input  [`TL_D_WIDTH_DATA-1:0]     biu_i_tl_d_data,
  input  [`TL_D_WIDTH_CORRUPT-1:0]  biu_i_tl_d_corrupt,
  input                             biu_i_tl_d_valid,
  output                            biu_o_tl_d_ready
);

  wire is_itim_addr = ((biu_i_daddr >= 'h0000_0000) && (biu_i_daddr < 'h0000_1000));
  wire is_dtim_addr = ((biu_i_daddr >= 'h0000_1000) && (biu_i_daddr < 'h0000_2000));
  wire is_mmio_addr = ((biu_i_daddr >= 'h0000_2000) && (biu_i_daddr < 'h0000_3000));

  
  assign biu_o_itim_addr = biu_i_iaddr[11:0];
  assign biu_o_idata = biu_i_itim_rdata;

  assign biu_o_dtim_addr = biu_i_daddr[11:0] - 'h0000_1000;
  assign biu_o_dtim_wmask = is_dtim_addr ? biu_i_dwmask : 'b0000;
  assign biu_o_dtim_wdata = biu_i_dwdata;




  assign biu_o_tl_a_opcode = biu_i_is_store ? `TL_A_MSG_PUTFULLDATA_OPCODE : `TL_A_MSG_GET_OPCODE;
  assign biu_o_tl_a_param = biu_i_is_store ? `TL_A_MSG_PUTFULLDATA_PARAM : `TL_A_MSG_GET_PARAM;
  assign biu_o_tl_a_size = 'h2;
  assign biu_o_tl_a_source = 'h0;
  assign biu_o_tl_a_address = biu_i_daddr - 'h0000_2000;
  assign biu_o_tl_a_mask = is_mmio_addr ? biu_i_dwmask : 'b0000;
  assign biu_o_tl_a_data = biu_i_dwdata;
  assign biu_o_tl_a_corrupt = 'b0;
  assign biu_o_tl_a_valid = (biu_i_is_load || biu_i_is_store) && is_mmio_addr;
  
  assign biu_o_tl_d_ready = 'b1;
  assign biu_o_halt = biu_o_tl_a_valid && !biu_i_tl_d_valid;




  assign biu_o_drdata = is_itim_addr ? biu_i_itim_rdata :
                        is_dtim_addr ? biu_i_dtim_rdata :
                        is_mmio_addr ? biu_i_tl_d_data :
                        'hCCCC_CCCC;

endmodule
