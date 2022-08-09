
module mmio (
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
  
  wire wen;
  
  assign wen = mmio_i_wmask !== 'b0000;
  
  assign is_gpio_idr = mmio_i_addr === 'h0000_0000;
  assign is_gpio_odr = mmio_i_addr === 'h0000_0004;
   
  assign mmio_o_rdata = is_gpio_idr ? gpio_idr_rdata :
                        is_gpio_odr ? gpio_odr_rdata : 
                        'hCCCC_CCCC;
  
  
  assign mmio_o_gpio_led = gpio_odr_rdata[3:0];
  
  DFF_REG #(.N(32)) u_gpio_idr (
    .C(clk),
    .D({24'h0, mmio_o_gpio_sw, mmio_o_gpio_btn}),
    .Q(gpio_idr_rdata)
  );
  
  DFF_REG_RCE #(.N(32)) u_gpio_odr (
    .C(clk),
    .R(rst),
    .CE(is_gpio_odr & wen),
    .D(mmio_i_wdata),
    .Q(gpio_odr_rdata)
  );

endmodule
