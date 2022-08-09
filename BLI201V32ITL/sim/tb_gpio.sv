`timescale 1ns / 1ns

`include "bli201v32i_tl_defines.vh"

module tb_gpio();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always
    #(CLOCK_PERIOD/2) clk = ~clk;


  task SYS_reset;
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


  //////////////////////////////////
  // TL Master                    //
  //////////////////////////////////

  reg [2:0]   tl_a_opcode;    initial tl_a_opcode  = 'b0;
  reg [2:0]   tl_a_param;     initial tl_a_param   = 'b0;
  reg [2:0]   tl_a_size;      initial tl_a_size    = 'b0;
  reg [0:0]   tl_a_source;    initial tl_a_source  = 'b0;
  reg [31:0]  tl_a_address;   initial tl_a_address = 'b0;
  reg [3:0]   tl_a_mask;      initial tl_a_mask    = 'b0;
  reg [31:0]  tl_a_data;      initial tl_a_data    = 'b0;
  reg         tl_a_corrupt;   initial tl_a_corrupt = 'b0;
  reg         tl_a_valid;     initial tl_a_valid   = 'b0;
  wire        tl_a_ready;
    
  wire [2:0]  tl_d_opcode;
  wire [1:0]  tl_d_param;
  wire [2:0]  tl_d_size;
  wire [0:0]  tl_d_source;
  wire [0:0]  tl_d_sink;
  wire        tl_d_denied;
  wire [31:0] tl_d_data;
  wire        tl_d_corrupt;
  wire        tl_d_valid;
  reg         tl_d_ready;     initial tl_d_ready   = 'b0;

  parameter tl_log_quiet = 0;

  task TL_PutFullData;
    input  [2:0]  size;
    input  [0:0]  source;
    input  [31:0] address;
    input  [4:0]  mask;
    input  [31:0] data;

    begin
      tl_a_opcode   <= `TL_A_MSG_PUTFULLDATA_OPCODE; // Must be PutFullData(0).
      tl_a_param    <= `TL_A_MSG_PUTFULLDATA_PARAM;  // Reserved; must be 0
      tl_a_size     <= $clog2(size);                // 2^n bytes will be written by the slave.
      tl_a_source   <= source;                       // The master source identier issuing this request.
      tl_a_address  <= address;                      // The target address of the Access, in bytes.
      tl_a_mask     <= mask;                         // Byte lanes to be written; must be contiguous
      tl_a_corrupt  <= 1'b0;                         // Whether this beat of data is corrupt.
      tl_a_data     <= data;                         // Data payload to be written.
      
      @(posedge clk);
      
      $display("%d [TL PutFullData]: <addr: 0x%h (%d), size: %d, mask: %b, data: 0x%h (%d)>", $time, tl_a_address, tl_a_address, size, tl_a_mask, tl_a_data, tl_a_data);


      fork
        begin
          // begin transaction
          if (!tl_log_quiet) $display("%d [TL PutFullData]:  asserting ch A VALID...", $time);
          tl_a_valid <= 'b1;
          
          if (!tl_log_quiet) $display("%d [TL PutFullData]:  waiting slave ch A READY...", $time);
          while (tl_a_ready !== 'b1) begin
            @(posedge clk);
          end
          
          // register the transaction
          @(posedge clk);
          
          if (!tl_log_quiet) $display("%d [TL PutFullData]:  finish ch A transaction.", $time);
          tl_a_valid <= 'b0;
        end
        begin
          if (!tl_log_quiet) $display("%d [TL PutFullData]:  asserting ch D READY...", $time);

          // D ready should be asserted at same clock cycle as A valid raising
          tl_d_ready <= 'b1;

          if (!tl_log_quiet) $display("%d [TL PutFullData]:  waiting slave ch D VALID...", $time);
          while (tl_d_valid !== 'b1) begin
            @(posedge clk);
          end

          // error checking
          if (tl_d_opcode !== `TL_D_MSG_ACCESSACK_OPCODE)   $display("%d [TL PutFullData]: ERROR: response opcode incorrect!", $time);
          if (tl_d_param !== `TL_D_MSG_ACCESSACK_PARAM)    $display("%d [TL PutFullData]: ERROR: response param incorrect!", $time);
          if (tl_d_size !== tl_a_size)                      $display("%d [TL PutFullData]: ERROR: response size mismatch!", $time); 
          if (tl_d_source !== tl_a_source)                  $display("%d [TL PutFullData]: ERROR: response source mismatch!", $time); 
          if (tl_d_denied !== 'b0)                          $display("%d [TL PutFullData]: WARNING: response denied!", $time);
          if (tl_d_corrupt !== 'b0)                         $display("%d [TL PutFullData]: WARNING: response corrupted!", $time);
          
          // register the transaction
          @(posedge clk);
          
          if (!tl_log_quiet) $display("%d [TL PutFullData]: finish ch D transaction.", $time);
        end
      join
    end
  endtask
  
  
  task TL_Get;
    input  [2:0]  size;
    input  [0:0]  source;
    input  [31:0] address;
    input  [4:0]  mask;
    output [31:0] data;

    begin
      tl_a_opcode   <= `TL_A_MSG_GET_OPCODE;        // Must be PutFullData(0).
      tl_a_param    <= `TL_A_MSG_GET_PARAM;         // Reserved; must be 0
      tl_a_size     <= $clog2(size);                // 2^n bytes will be written by the slave.
      tl_a_source   <= source;                      // The master source identier issuing this request.
      tl_a_address  <= address;                     // The target address of the Access, in bytes.
      tl_a_mask     <= mask;                        // Byte lanes to be written; must be contiguous
      tl_a_corrupt  <= 1'b0;                        // Whether this beat of data is corrupt.
      tl_a_data     <= 'h0;                         // Data payload to be written.
      
      $display("%d [TL Get]: <addr: 0x%h (%d), size: %d, mask: %b>", $time, tl_a_address, tl_a_address, size, tl_a_mask);

      @(posedge clk);

      fork
        begin
          // begin transaction
          if (!tl_log_quiet) $display("%d [TL Get]:  asserting ch A VALID...", $time);
          tl_a_valid <= 'b1;
          
          if (!tl_log_quiet) $display("%d [TL Get]:  waiting slave ch A READY...", $time);
          while (tl_a_ready !== 'b1) begin
            @(posedge clk);
          end
          
          // register the transaction
          @(posedge clk);
          
          if (!tl_log_quiet) $display("%d [TL Get]:  finish ch A transaction.", $time);
          tl_a_valid <= 'b0;
        end
        begin
          if (!tl_log_quiet) $display("%d [TL Get]:  asserting ch D READY...", $time);

          // D ready should be asserted at same clock cycle as A valid raising
          tl_d_ready <= 'b1;

          if (!tl_log_quiet) $display("%d [TL Get]:  waiting slave ch D VALID...", $time);
          while (tl_d_valid !== 'b1) begin
            @(posedge clk);
          end

          // register the transaction
          @(posedge clk);
          
          // error checking
          if (tl_d_opcode !== `TL_D_MSG_ACCESSACKDATA_OPCODE)   $display("%d [TL Get]: ERROR: response opcode incorrect!", $time);
          if (tl_d_param !== `TL_D_MSG_ACCESSACKDATA_PARAM)    $display("%d [TL Get]: ERROR: response param incorrect!", $time);
          if (tl_d_size !== tl_a_size)                      $display("%d [TL Get]: ERROR: response size mismatch!", $time); 
          if (tl_d_source !== tl_a_source)                  $display("%d [TL Get]: ERROR: response source mismatch!", $time); 
          if (tl_d_denied !== 'b0)                          $display("%d [TL Get]: WARNING: response denied!", $time);
          if (tl_d_corrupt !== 'b0)                         $display("%d [TL Get]: WARNING: response corrupted!", $time);
          
          if (!tl_log_quiet) $display("%d [TL Get]:  finish ch D transaction.", $time);
          
          $display("%d [TL Get]: <Response: data: 0x%h (%d)>", $time, tl_d_data, tl_d_data);
          data <= tl_d_data;
        end
      join
    end
  endtask



  reg [3:0] sw;     initial sw = 'b1111;
  reg [3:0] btn;    initial btn = 'b0000;
  wire [3:0] led;

  gpio #(
  ) DUT (
    .clk(clk),
    .rst(rst),

    .gpio_i_tl_a_opcode(tl_a_opcode),
    .gpio_i_tl_a_param(tl_a_param),
    .gpio_i_tl_a_size(tl_a_size),
    .gpio_i_tl_a_source(tl_a_source),
    .gpio_i_tl_a_address(tl_a_address),
    .gpio_i_tl_a_mask(tl_a_mask),
    .gpio_i_tl_a_data(tl_a_data),
    .gpio_i_tl_a_corrupt(tl_a_corrupt),
    .gpio_i_tl_a_valid(tl_a_valid),
    .gpio_o_tl_a_ready(tl_a_ready),
    
    .gpio_o_tl_d_opcode(tl_d_opcode),
    .gpio_o_tl_d_param(tl_d_param),
    .gpio_o_tl_d_size(tl_d_size),
    .gpio_o_tl_d_source(tl_d_source),
    .gpio_o_tl_d_sink(tl_d_sink),
    .gpio_o_tl_d_denied(tl_d_denied),
    .gpio_o_tl_d_data(tl_d_data),
    .gpio_o_tl_d_corrupt(tl_d_corrupt),
    .gpio_o_tl_d_valid(tl_d_valid),
    .gpio_i_tl_d_ready(tl_d_ready),

    .gpio_i_sw(sw),
    .gpio_i_btn(btn),
    .gpio_o_led(led)
  );



  reg [31:0] tl_data_output;

  initial begin
    SYS_reset();
    
    repeat(8) @(posedge clk);
    
    
      begin
        TL_PutFullData('d4, 'h0, 'h0000_0004, 'b0001, 'h0000_0041);
        
        TL_Get('d4, 'h0, 'h0000_0000, 'b0001, tl_data_output);
      end
    
    repeat(100) @(posedge clk);
    #100;
    $finish();

  end 

endmodule