`timescale 1ns/1ns

module z1top #(
  parameter IMEM_HEX = "firmware.hex",
  parameter IMEM_BIN = ""
) (
  input         CLK100MHZ,
  input         ck_rst,
  
  input         uart_rxd_out,
  output        uart_txd_in,
  
  input  [3:0]  sw,
  output [3:0]  led,
  input  [3:0]  btn
);

  wire clk;  // clock is at fixed 100MHz
  wire rst;  // reset signal is active low
  
  assign clk = CLK100MHZ;
  assign rst = ck_rst;

  wire [11:0] core2itim_addr;
  wire [31:0] itim2core_rdata;

  wire [11:0] core2dtim_addr;
  wire [3:0]  core2dtim_wmask;
  wire [31:0] core2dtim_wdata;
  wire [31:0] dtim2core_rdata;
  
  wire [31:0] core2mmio_addr;
  wire [3:0]  core2mmio_wmask;
  wire [31:0] core2mmio_wdata;
  wire [31:0] mmio2core_rdata;
  
  ila_0 u_ila_0 (
    .clk(clk),
    .probe0(core2itim_addr),
    .probe1(itim2core_rdata),
    .probe2(led)
  );
  
  core u_core (
    .clk(clk),
    .rst(rst),
    
    .core_o_itim_addr(core2itim_addr),
    .core_i_itim_rdata(itim2core_rdata),
    
    .core_o_dtim_addr(core2dtim_addr),
    .core_o_dtim_wmask(core2dtim_wmask),
    .core_o_dtim_wdata(core2dtim_wdata),
    .core_i_dtim_rdata(dtim2core_rdata),
    
    .core_o_mmio_addr(core2mmio_addr),
    .core_o_mmio_wmask(core2mmio_wmask),
    .core_o_mmio_wdata(core2mmio_wdata),
    .core_i_mmio_rdata(mmio2core_rdata)
  );

  itim #(
    .IMEM_HEX(IMEM_HEX),
    .IMEM_BIN(IMEM_BIN)
  ) u_itim (
    .clk(clk),
    .itim_i_addr(core2itim_addr),
    .itim_o_rdata(itim2core_rdata)
  );

  dtim u_dtim (
    .clk(clk),
    .dtim_i_addr(core2dtim_addr),
    .dtim_i_wmask(core2dtim_wmask),
    .dtim_i_wdata(core2dtim_wdata),
    .dtim_o_rdata(dtim2core_rdata)
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
