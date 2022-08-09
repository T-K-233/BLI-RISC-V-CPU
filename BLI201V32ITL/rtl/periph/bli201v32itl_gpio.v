`include "bli201v32itl_tl_defines.vh"

module gpio (
  input  clk,
  input  rst,
  
  input  [`TL_A_WIDTH_OPCODE-1:0]   gpio_i_tl_a_opcode,
  input  [`TL_A_WIDTH_PARAM-1:0]    gpio_i_tl_a_param,
  input  [`TL_A_WIDTH_SIZE-1:0]     gpio_i_tl_a_size,
  input  [`TL_A_WIDTH_SOURCE-1:0]   gpio_i_tl_a_source,
  input  [`TL_A_WIDTH_ADDRESS-1:0]  gpio_i_tl_a_address,
  input  [`TL_A_WIDTH_MASK-1:0]     gpio_i_tl_a_mask,
  input  [`TL_A_WIDTH_DATA-1:0]     gpio_i_tl_a_data,
  input  [`TL_A_WIDTH_CORRUPT-1:0]  gpio_i_tl_a_corrupt,
  input                             gpio_i_tl_a_valid,
  output                            gpio_o_tl_a_ready,
  
  output [`TL_D_WIDTH_OPCODE-1:0]   gpio_o_tl_d_opcode,
  output [`TL_D_WIDTH_PARAM-1:0]    gpio_o_tl_d_param,
  output [`TL_D_WIDTH_SIZE-1:0]     gpio_o_tl_d_size,
  output [`TL_D_WIDTH_SOURCE-1:0]   gpio_o_tl_d_source,
  output [`TL_D_WIDTH_SINK-1:0]     gpio_o_tl_d_sink,
  output [`TL_D_WIDTH_DENIED-1:0]   gpio_o_tl_d_denied,
  output [`TL_D_WIDTH_DATA-1:0]     gpio_o_tl_d_data,
  output [`TL_D_WIDTH_CORRUPT-1:0]  gpio_o_tl_d_corrupt,
  output                            gpio_o_tl_d_valid,
  input                             gpio_i_tl_d_ready,
  
  output [3:0] gpio_o_gpio_led,
  input  [3:0] gpio_i_gpio_btn,
  input  [3:0] gpio_i_gpio_sw
);

  wire [31:0] address;
  wire        w_en;
  wire [31:0] w_data;
  wire [31:0] r_data;
  
  wire is_gpio_idr;
  wire is_gpio_odr;

  wire [31:0] gpio_idr_rdata;
  wire [31:0] gpio_odr_rdata;
  
  assign is_gpio_idr = address === 'h0000_0000;
  assign is_gpio_odr = address === 'h0000_0004;
   
  assign r_data = is_gpio_idr ? gpio_idr_rdata :
                  is_gpio_odr ? gpio_odr_rdata : 
                  'hCCCC_CCCC;
  
  
  assign gpio_o_gpio_led = gpio_odr_rdata[3:0];
  
  tl2reg_adapter u_adapter (
    .clk(clk),
    .rst(rst),
    
    .adapter_i_tl_a_opcode(gpio_i_tl_a_opcode),
    .adapter_i_tl_a_param(gpio_i_tl_a_param),
    .adapter_i_tl_a_size(gpio_i_tl_a_size),
    .adapter_i_tl_a_source(gpio_i_tl_a_source),
    .adapter_i_tl_a_address(gpio_i_tl_a_address),
    .adapter_i_tl_a_mask(gpio_i_tl_a_mask),
    .adapter_i_tl_a_data(gpio_i_tl_a_data),
    .adapter_i_tl_a_corrupt(gpio_i_tl_a_corrupt),
    .adapter_i_tl_a_valid(gpio_i_tl_a_valid),
    .adapter_o_tl_a_ready(gpio_o_tl_a_ready),

    .adapter_o_tl_d_opcode(gpio_o_tl_d_opcode),
    .adapter_o_tl_d_param(gpio_o_tl_d_param),
    .adapter_o_tl_d_size(gpio_o_tl_d_size),
    .adapter_o_tl_d_source(gpio_o_tl_d_source),
    .adapter_o_tl_d_sink(gpio_o_tl_d_sink),
    .adapter_o_tl_d_denied(gpio_o_tl_d_denied),
    .adapter_o_tl_d_data(gpio_o_tl_d_data),
    .adapter_o_tl_d_corrupt(gpio_o_tl_d_corrupt),
    .adapter_o_tl_d_valid(gpio_o_tl_d_valid),
    .adapter_i_tl_d_ready(gpio_i_tl_d_ready),
    
    .adapter_o_address(address),
    .adapter_o_r_en(),
    .adapter_o_w_en(w_en),
    .adapter_o_wmask(),
    .adapter_o_wdata(w_data),
    .adapter_i_rdata(r_data),
    .adapter_i_err('b0)
  );

  DFF_REG #(.N(32)) u_gpio_idr (
    .C(clk),
    .D({24'h0, gpio_i_gpio_btn, gpio_i_gpio_sw}),
    .Q(gpio_idr_rdata)
  );
  
  DFF_REG_RCE #(.N(32)) u_gpio_odr (
    .C(clk),
    .R(rst),
    .CE(is_gpio_odr && w_en),
    .D(w_data),
    .Q(gpio_odr_rdata)
  );

endmodule
