`timescale 1ns/1ns

`include "bli201v32itl_tl_defines.vh"

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
  wire clk_locked;

  assign rst = clk_locked && ck_rst;
  

  clk_wiz_0 u_clk_wiz_0 (
    // Clock out ports  
    .clk_out1(clk),
    // Status and control signals               
    .resetn(ck_rst),
    .locked(clk_locked),
  // Clock in ports
    .clk_in1(CLK100MHZ)
  );

  
  wire [`TL_A_WIDTH_OPCODE-1:0]   core2gpio_tl_a_opcode;
  wire [`TL_A_WIDTH_PARAM-1:0]    core2gpio_tl_a_param;
  wire [`TL_A_WIDTH_SIZE-1:0]     core2gpio_tl_a_size;
  wire [`TL_A_WIDTH_SOURCE-1:0]   core2gpio_tl_a_source;
  wire [`TL_A_WIDTH_ADDRESS-1:0]  core2gpio_tl_a_address;
  wire [`TL_A_WIDTH_MASK-1:0]     core2gpio_tl_a_mask;
  wire [`TL_A_WIDTH_DATA-1:0]     core2gpio_tl_a_data;
  wire [`TL_A_WIDTH_CORRUPT-1:0]  core2gpio_tl_a_corrupt;
  wire                            core2gpio_tl_a_valid;
  wire                            gpio2core_tl_a_ready;

  wire [`TL_D_WIDTH_OPCODE-1:0]   gpio2core_tl_d_opcode;
  wire [`TL_D_WIDTH_PARAM-1:0]    gpio2core_tl_d_param;
  wire [`TL_D_WIDTH_SIZE-1:0]     gpio2core_tl_d_size;
  wire [`TL_D_WIDTH_SOURCE-1:0]   gpio2core_tl_d_source;
  wire [`TL_D_WIDTH_SINK-1:0]     gpio2core_tl_d_sink;
  wire [`TL_D_WIDTH_DENIED-1:0]   gpio2core_tl_d_denied;
  wire [`TL_D_WIDTH_DATA-1:0]     gpio2core_tl_d_data;
  wire [`TL_D_WIDTH_CORRUPT-1:0]  gpio2core_tl_d_corrupt;
  wire                            gpio2core_tl_d_valid;
  wire                            core2gpio_tl_d_ready;


  
  //ila_0 u_ila_0 (
  //  .clk(clk),
  //  .probe0(core2itim_addr),
  //  .probe1(itim2core_rdata)
  //);
  
  core u_core (
    .clk(clk),
    .rst(rst),
    
    .core_o_tl_a_opcode(core2gpio_tl_a_opcode),
    .core_o_tl_a_param(core2gpio_tl_a_param),
    .core_o_tl_a_size(core2gpio_tl_a_size),
    .core_o_tl_a_source(core2gpio_tl_a_source),
    .core_o_tl_a_address(core2gpio_tl_a_address),
    .core_o_tl_a_mask(core2gpio_tl_a_mask),
    .core_o_tl_a_data(core2gpio_tl_a_data),
    .core_o_tl_a_corrupt(core2gpio_tl_a_corrupt),
    .core_o_tl_a_valid(core2gpio_tl_a_valid),
    .core_i_tl_a_ready(gpio2core_tl_a_ready),
    
    .core_i_tl_d_opcode(gpio2core_tl_d_opcode),
    .core_i_tl_d_param(gpio2core_tl_d_param),
    .core_i_tl_d_size(gpio2core_tl_d_size),
    .core_i_tl_d_source(gpio2core_tl_d_source),
    .core_i_tl_d_sink(gpio2core_tl_d_sink),
    .core_i_tl_d_denied(gpio2core_tl_d_denied),
    .core_i_tl_d_data(gpio2core_tl_d_data),
    .core_i_tl_d_corrupt(gpio2core_tl_d_corrupt),
    .core_i_tl_d_valid(gpio2core_tl_d_valid),
    .core_o_tl_d_ready(core2gpio_tl_d_ready)
  );

  
  gpio u_gpio (
    .clk(clk),
    .rst(rst),
    
    .gpio_i_tl_a_opcode(core2gpio_tl_a_opcode),
    .gpio_i_tl_a_param(core2gpio_tl_a_param),
    .gpio_i_tl_a_size(core2gpio_tl_a_size),
    .gpio_i_tl_a_source(core2gpio_tl_a_source),
    .gpio_i_tl_a_address(core2gpio_tl_a_address),
    .gpio_i_tl_a_mask(core2gpio_tl_a_mask),
    .gpio_i_tl_a_data(core2gpio_tl_a_data),
    .gpio_i_tl_a_corrupt(core2gpio_tl_a_corrupt),
    .gpio_i_tl_a_valid(core2gpio_tl_a_valid),
    .gpio_o_tl_a_ready(gpio2core_tl_a_ready),
    
    .gpio_o_tl_d_opcode(gpio2core_tl_d_opcode),
    .gpio_o_tl_d_param(gpio2core_tl_d_param),
    .gpio_o_tl_d_size(gpio2core_tl_d_size),
    .gpio_o_tl_d_source(gpio2core_tl_d_source),
    .gpio_o_tl_d_sink(gpio2core_tl_d_sink),
    .gpio_o_tl_d_denied(gpio2core_tl_d_denied),
    .gpio_o_tl_d_data(gpio2core_tl_d_data),
    .gpio_o_tl_d_corrupt(gpio2core_tl_d_corrupt),
    .gpio_o_tl_d_valid(gpio2core_tl_d_valid),
    .gpio_i_tl_d_ready(core2gpio_tl_d_ready),
    
    .gpio_o_gpio_led(led),
    .gpio_i_gpio_btn(btn),
    .gpio_i_gpio_sw(sw)
  );

endmodule
