
module mmio #(
  parameter ROM_ADDR_BITS = 12,
  parameter IMEM_HEX = "",
  parameter IMEM_BIN = ""
) (
  input  clk,
  input  rst,
  input  [31:0] mmio_i_addr,
  input  [3:0]  mmio_i_wmask,
  input  [31:0] mmio_i_wdata,
  output [31:0] mmio_o_rdata,
  
  output [3:0] mmio_o_gpio_led,
  input  [3:0] mmio_i_gpio_btn,
  input  [3:0] mmio_i_gpio_sw
);
  
  wire is_gpio_idr;
  wire is_gpio_odr;

  wire [31:0] gpio_idr_rdata;
  wire [31:0] gpio_odr_rdata;
  
  assign is_gpio_idr = mmio_i_addr === 'h0000_0000;
  assign is_gpio_odr = mmio_i_addr === 'h0000_0004;
   
  assign mmio_o_rdata = is_gpio_idr ? gpio_idr_rdata :
                        is_gpio_odr ? gpio_odr_rdata : 
                        'hCCCC_CCCC;
  
  
  assign mmio_o_gpio_led = gpio_odr_rdata[3:0];
  
  register #(.N(32)) u_gpio_idr (
    .clk(clk),
    .d({16'h0, mmio_o_gpio_sw, mmio_o_gpio_btn}),
    .q(gpio_idr_rdata)
  );
  
  register_rst_en #(.N(32)) u_gpio_odr (
    .clk(clk),
    .rst(rst),
    .en(is_gpio_odr),
    .d(mmio_i_wdata),
    .q(gpio_odr_rdata)
  );

endmodule
