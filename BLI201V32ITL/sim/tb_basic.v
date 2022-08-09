`timescale 1ns / 1ns

module tb_basic();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always
    #(CLOCK_PERIOD/2) clk = ~clk;

  z1top #(
    .IMEM_HEX("firmware.hex")
  ) DUT(
    .CLK100MHZ(clk),
    .ck_rst(rst),
    
    
    .sw('b0101),
    .led(),
    .btn('b1010)
  );
    
  initial begin
    #0;
    rst = 0;
    
    $display("[TEST]\tRESET pulled LOW.");
    
    repeat(2) @(posedge clk);
    
    @(negedge clk);
    rst = 1;
    
    $display("[TEST]\tRESET pulled HIGH.");
    
    repeat(2000) @(posedge clk); #1;
    
    
    $finish();
  end 

endmodule