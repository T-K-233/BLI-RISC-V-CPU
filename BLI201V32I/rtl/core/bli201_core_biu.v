
module biu (
  input  clk,
  input  rst,
  
  output        biu_o_halt,

  input  [31:0] biu_i_iaddr,
  output [31:0] biu_o_idata,

  input  [31:0] biu_i_daddr,
  input  [3:0]  biu_i_dwmask,
  input  [31:0] biu_i_dwdata,
  output [31:0] biu_o_drdata,

  output [11:0] biu_o_itim_addr,
  input  [31:0] biu_i_itim_rdata,

  output [11:0] biu_o_dtim_addr,
  output [3:0]  biu_o_dtim_wmask,
  output [31:0] biu_o_dtim_wdata,
  input  [31:0] biu_i_dtim_rdata,
  
  output [31:0] biu_o_mmio_addr,
  output [3:0]  biu_o_mmio_wmask,
  output [31:0] biu_o_mmio_wdata,
  input  [31:0] biu_i_mmio_rdata
);

  wire is_itim_addr = ((biu_i_daddr >= 'h0000_0000) && (biu_i_daddr < 'h0000_1000));
  wire is_dtim_addr = ((biu_i_daddr >= 'h0000_1000) && (biu_i_daddr < 'h0000_2000));
  wire is_mmio_addr = ((biu_i_daddr >= 'h0000_2000) && (biu_i_daddr < 'h0000_3000));

  assign biu_o_halt = 'b0;
  
  assign biu_o_itim_addr = biu_i_iaddr[11:0];
  assign biu_o_idata = biu_i_itim_rdata;

  assign biu_o_dtim_addr = biu_i_daddr[11:0] - 'h0000_1000;
  assign biu_o_dtim_wmask = is_dtim_addr ? biu_i_dwmask : 'b0000;
  assign biu_o_dtim_wdata = biu_i_dwdata;
  
  assign biu_o_mmio_addr = biu_i_daddr - 'h0000_2000;
  assign biu_o_mmio_wmask = is_mmio_addr ? biu_i_dwmask : 'b0000;
  assign biu_o_mmio_wdata = biu_i_dwdata;
  
  assign biu_o_drdata = is_itim_addr ? biu_i_itim_rdata :
                        is_dtim_addr ? biu_i_dtim_rdata :
                        is_mmio_addr ? biu_i_mmio_rdata :
                        'hCCCC_CCCC;

endmodule
