`timescale 1ns / 1ns

`include "bli201v32i_tl_defines.vh"

module tb_uart();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always
    #(CLOCK_PERIOD/2) clk = ~clk;


  reg [2:0] tl_a_opcode;   initial tl_a_opcode  = 'b0;
  reg [2:0] tl_a_param;    initial tl_a_param   = 'b0;
  reg [3:0] tl_a_size;     initial tl_a_size    = 'b0;
  reg [0:0] tl_a_source;   initial tl_a_source  = 'b0;
  reg [24:0] tl_a_address; initial tl_a_address = 'b0;
  reg [3:0] tl_a_mask;     initial tl_a_mask    = 'b0;
  reg [31:0] tl_a_data;    initial tl_a_data    = 'b0;
  reg tl_a_corrupt;        initial tl_a_corrupt = 'b0;
  reg tl_a_valid;          initial tl_a_valid   = 'b0;
  wire tl_a_ready;
    
  wire [2:0] tl_d_opcode;
  wire [1:0] tl_d_param;
  wire [3:0] tl_d_size;
  wire [0:0] tl_d_source;
  wire [0:0] tl_d_sink;
  wire tl_d_denied;
  wire [31:0] tl_d_data;
  wire tl_d_corrupt;
  wire tl_d_valid;
  reg tl_d_ready;          initial tl_d_ready   = 'b0;


  task reset;
    begin
      #0;
      rst = 0;
      $display("[TEST]\tRESET pulled LOW.");
      repeat(2) @(posedge clk);
      @(negedge clk);
      rst = 1;
      $display("[TEST]\tRESET pulled HIGH.");
    end
  endtask



  reg dut_uart_rx;
  wire dut_uart_tx;
  reg [7:0] dut_uart_tx_char;
  initial dut_uart_rx = 'b1; 
  
  task UART_Transmit;
    input [7:0] char;
    begin
      dut_uart_rx = 'b0;      // START
      #80;
      dut_uart_rx = char[0];  // bit 0
      #80;
      dut_uart_rx = char[1];  // bit 1
      #80;
      dut_uart_rx = char[2];  // bit 2
      #80;
      dut_uart_rx = char[3];  // bit 3
      #80;
      dut_uart_rx = char[4];  // bit 4
      #80;
      dut_uart_rx = char[5];  // bit 5
      #80;
      dut_uart_rx = char[6];  // bit 6
      #80;
      dut_uart_rx = char[7];  // bit 7
      #80;
      dut_uart_rx = 'b1;      // STOP
      #80;
    end
  endtask
  
  task UART_Receive;
    begin
      @(negedge dut_uart_tx);      // START
//      $display("%t [TEST]\tReceived DUT TX START.", $time);
      #40;
      #80;
      dut_uart_tx_char[0] = dut_uart_tx;  // bit 0
      #80;
      dut_uart_tx_char[1] = dut_uart_tx;  // bit 1
      #80;
      dut_uart_tx_char[2] = dut_uart_tx;  // bit 2
      #80;
      dut_uart_tx_char[3] = dut_uart_tx;  // bit 3
      #80;
      dut_uart_tx_char[4] = dut_uart_tx;  // bit 4
      #80;
      dut_uart_tx_char[5] = dut_uart_tx;  // bit 5
      #80;
      dut_uart_tx_char[6] = dut_uart_tx;  // bit 6
      #80;
      dut_uart_tx_char[7] = dut_uart_tx;  // bit 7
      #80;
      if (dut_uart_tx !== 'b1) begin
        $display("%t [TEST]\tDUT TX Frame ERROR.", $time);
      end
      ;      // STOP
      #40;
      $display("%t [TEST]\tReceived DUT TX %d / 0x%h.", $time, dut_uart_tx_char, dut_uart_tx_char);
    end
  endtask
  
  
  task TL_PutFullData;
    input [7:0] size;
    input [0:0] source;
    input [31:0] address;
    input [31:0] mask;
    input [255:0] data;
      
    begin
      integer i;
      tl_a_opcode = `TL_A_MSG_PUTFULLDATA_OPCODE;   // Must be PutFullData(0).
      tl_a_param = `TL_A_MSG_PUTFULLDATA_PARAM;     // Reserved; must be 0
      tl_a_size =  $clog2(size);        // 2^n bytes will be written by the slave.
      tl_a_source = source;             // The master source identier issuing this request.
      tl_a_address = address;           // The target address of the Access, in bytes.
      tl_a_mask = mask;                 // Byte lanes to be written; must be contiguous
      tl_a_corrupt = 1'b0;              // Whether this beat of data is corrupt.
      tl_a_data = data;                 // Data payload to be written.
      
      
      tl_a_valid = 'b1;
      #1;
      
      $display("%d [TL PutFullData]: waiting slave device READY...", $time);
      while (tl_a_ready !== 'b1) begin
        @(posedge clk);
      end
      
      for (i=0; i<size/4; i+=1) begin
        tl_a_data = data[31:0];
        data = {32'h0, data[255-32:32]};
        $display("%d [TL PutFullData]: sending PUTFULLDATA <addr: %h, size: %d, data: %h>", $time, tl_a_address, 1<<tl_a_size, tl_a_data);
        @(posedge clk);
      end
      @(posedge clk);
      tl_a_valid = 'b0;
      tl_d_ready = 'b1;
      
      $display("%d [TL PutFullData]: waiting response...", $time);
      while (tl_d_valid !== 'b1) begin
        @(posedge clk);
      end
      
      if (tl_d_opcode !== `TL_D_MSG_ACCESSACKDATA_OPCODE) $display("%d [TL PutFullData]: ERROR: response type mismatch!", $time);
      if (tl_d_size !== tl_a_size) $display("%d [TL PutFullData]: ERROR: response size mismatch!", $time); 
      if (tl_d_denied !== 'b0) $display("%d [TL PutFullData]: ERROR: response denied!", $time);
      
      $display("%d [TL PutFullData]: get response.", $time);
    end
  endtask
  
  task TL_Get;
    input [2:0] size;
    input [0:0] source;
    input [31:0] address;
    input [31:0] mask;
    output [255:0] data;
    
    begin
      integer i;
      tl_a_opcode = `TL_A_MSG_GET_OPCODE;   // Must be Get (4).
      tl_a_param = `TL_A_MSG_GET_PARAM;     // Reserved; must be 0
      tl_a_size =  $clog2(size);        // 2^n bytes will be read by the slave and returned.
      tl_a_source = source;             // The master source identier issuing this request.
      tl_a_address = address;           // The target address of the Access, in bytes.
      tl_a_mask = mask;                 // Byte lanes to be read from.
      tl_a_corrupt = 1'b0;              //  Reserved; must be 0.
      tl_a_data = 'hCCCCCCCC;           // Ignored; can be any value.
      
      $display("%d [TL Get]: waiting slave device READY...", $time);
      while (tl_a_ready != 'b1) begin
        @(posedge clk);
      end
      tl_a_valid = 'b1;
      
      $display("%d [TL Get]: sending GET <addr: %h, size: %d>", $time, tl_a_address, 1<<tl_a_size);
      tl_a_valid = 'b1;
      @(posedge clk);
      tl_a_valid = 'b0;
      tl_d_ready = 'b1;
      
      $display("%d [TL Get]: waiting response...", $time);
      while (tl_d_valid !== 'b1) begin
        @(posedge clk);
      end
      
      if (tl_d_opcode != `TL_D_MSG_ACCESSACK_OPCODE) $display("%d [TL Get]: ERROR: response type mismatch!", $time);
      if (tl_d_size != tl_a_size) $display("%d [TL Get]: ERROR: response size mismatch!", $time); 
      if (tl_d_denied != 'b0) $display("%d [TL Get]: ERROR: response denied!", $time);
      
      data = 'h0;
      for (i=0; i<size/4; i+=1) begin
        $display("%d [TL Get]: get response %h", $time, tl_d_data);      
        data = data | (tl_d_data << (i*32));
        @(posedge clk);
      end
      $display("%d [TL Get]: get final response %h", $time, data);      
    end
  endtask


  uart #(
  ) DUT (
    .clk(clk),
    .rst(rst),

    .uart_i_itim_tl_a_opcode(tl_a_opcode),
    .uart_i_itim_tl_a_param(tl_a_param),
    .uart_i_itim_tl_a_size(tl_a_size),
    .uart_i_itim_tl_a_source(tl_a_source),
    .uart_i_itim_tl_a_address(tl_a_address),
    .uart_i_itim_tl_a_mask(tl_a_mask),
    .uart_i_itim_tl_a_data(tl_a_data),
    .uart_i_itim_tl_a_corrupt(tl_a_corrupt),
    .uart_i_itim_tl_a_valid(tl_a_valid),
    .uart_o_itim_tl_a_ready(tl_a_ready),
    
    .uart_o_itim_tl_d_opcode(tl_d_opcode),
    .uart_o_itim_tl_d_param(tl_d_param),
    .uart_o_itim_tl_d_size(tl_d_size),
    .uart_o_itim_tl_d_source(tl_d_source),
    .uart_o_itim_tl_d_sink(tl_d_sink),
    .uart_o_itim_tl_d_denied(tl_d_denied),
    .uart_o_itim_tl_d_data(tl_d_data),
    .uart_o_itim_tl_d_corrupt(tl_d_corrupt),
    .uart_o_itim_tl_d_valid(tl_d_valid),
    .uart_i_itim_tl_d_ready(tl_d_ready),

    /*
    * UART interface
    */
    .uart_i_rx(dut_uart_rx),
    .uart_o_tx(dut_uart_tx),

    /*
    * Status
    */
    .uart_o_tx_busy(),
    .uart_o_rx_busy(),
    .uart_o_rx_overrun_error(),
    .uart_o_rx_frame_error()
  );



  reg [31:0] tl_data_output;

  initial begin
    reset();
    
    repeat(8) @(posedge clk);
    
    tl_d_ready = 'b1;
    
    fork
      begin
        TL_PutFullData('d4, 'h0, 'h0000_0010, 'b0001, 'h0000_0040);
      end
      begin    
        UART_Receive();
      end
    join
    
    repeat(100) @(posedge clk);
    #100;
    $finish();


  end 

endmodule