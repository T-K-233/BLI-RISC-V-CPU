
module ifu (
  input  clk,
  input  rst,
  
  input         ifu_i_halt,
  input         ifu_i_is_jump,
  input         ifu_i_is_branch_taken,
  input  [31:0] ifu_i_pc_target,

  output [31:0] ifu_o_pc,
  output [31:0] ifu_o_inst,

  output [31:0] ifu_o_iaddr,
  input  [31:0] ifu_i_idata
);

  wire [31:0] next_pc;

  assign ifu_o_iaddr = ifu_o_pc;

  assign ifu_o_inst = ifu_i_idata;

  assign next_pc = (ifu_i_is_jump | ifu_i_is_branch_taken) ? ifu_i_pc_target : (ifu_o_pc + 'h04);

  register_rst_en #(.N(32)) u_program_counter (
    .clk(clk),
    .rst(rst),
    .en(!ifu_i_halt),
    .d(next_pc),
    .q(ifu_o_pc)
  );

endmodule