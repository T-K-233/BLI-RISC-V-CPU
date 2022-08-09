`timescale 1ns/1ns

module z1top #(
  parameter IMEM_HEX = "firmware.hex",
  parameter IMEM_BIN = ""
) (
  input         CLK100MHZ,
  input         ck_rst,
  
  input  [3:0]  sw,
  output [3:0]  led,
  input  [3:0]  btn
);

  wire clk;  // clock is at fixed 100MHz
  wire rst;  // reset signal is active low
  
  assign rst = ck_rst;
  

  clk_wiz_0 u_clk_wiz_0 (
    // Clock out ports  
    .clk_out1(clk),
    // Status and control signals               
    .resetn(rst), 
  // Clock in ports
    .clk_in1(CLK100MHZ)
  );

  wire [31:0] core2mmio_addr;
  wire [3:0]  core2mmio_wmask;
  wire [31:0] core2mmio_wdata;
  wire [31:0] mmio2core_rdata;
  
  //ila_0 u_ila_0 (
  //  .clk(clk),
  //  .probe0(core2itim_addr),
  //  .probe1(itim2core_rdata)
  //);
  
  core u_core (
    .clk(clk),
    .rst(rst),
    
    .core_o_mmio_addr(core2mmio_addr),
    .core_o_mmio_wmask(core2mmio_wmask),
    .core_o_mmio_wdata(core2mmio_wdata),
    .core_i_mmio_rdata(mmio2core_rdata)
  );

  
  mmio u_mmio (
    .clk(clk),
    .rst(rst),
    .mmio_i_addr(core2mmio_addr),
    .mmio_i_wmask(core2mmio_wmask),
    .mmio_i_wdata(core2mmio_wdata),
    .mmio_o_rdata(mmio2core_rdata),
    
    .mmio_o_gpio_led(led),
    .mmio_i_gpio_btn(btn),
    .mmio_i_gpio_sw(sw)
  );

endmodule
