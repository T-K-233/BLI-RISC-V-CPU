`include "bli201v32itl_tl_defines.vh"

module core #(
  parameter IMEM_HEX = "firmware.hex",
  parameter IMEM_BIN = ""
) (
  input  clk,
  input  rst,
  
  output [`TL_A_WIDTH_OPCODE-1:0]   core_o_tl_a_opcode,
  output [`TL_A_WIDTH_PARAM-1:0]    core_o_tl_a_param,
  output [`TL_A_WIDTH_SIZE-1:0]     core_o_tl_a_size,
  output [`TL_A_WIDTH_SOURCE-1:0]   core_o_tl_a_source,
  output [`TL_A_WIDTH_ADDRESS-1:0]  core_o_tl_a_address,
  output [`TL_A_WIDTH_MASK-1:0]     core_o_tl_a_mask,
  output [`TL_A_WIDTH_DATA-1:0]     core_o_tl_a_data,
  output [`TL_A_WIDTH_CORRUPT-1:0]  core_o_tl_a_corrupt,
  output                            core_o_tl_a_valid,
  input                             core_i_tl_a_ready,
  
  input  [`TL_D_WIDTH_OPCODE-1:0]   core_i_tl_d_opcode,
  input  [`TL_D_WIDTH_PARAM-1:0]    core_i_tl_d_param,
  input  [`TL_D_WIDTH_SIZE-1:0]     core_i_tl_d_size,
  input  [`TL_D_WIDTH_SOURCE-1:0]   core_i_tl_d_source,
  input  [`TL_D_WIDTH_SINK-1:0]     core_i_tl_d_sink,
  input  [`TL_D_WIDTH_DENIED-1:0]   core_i_tl_d_denied,
  input  [`TL_D_WIDTH_DATA-1:0]     core_i_tl_d_data,
  input  [`TL_D_WIDTH_CORRUPT-1:0]  core_i_tl_d_corrupt,
  input                             core_i_tl_d_valid,
  output                            core_o_tl_d_ready
);

  wire [31:0] ifu2idu_inst;
  wire [31:0] ifu2exu_pc;
  wire [31:0] ifu2wbu_pc;
  wire [31:0] ifu2biu_iaddr;

  assign ifu2wbu_pc = ifu2exu_pc;


  wire        idu2ifu_is_jump;
  wire [31:0] idu2exu_rs1_data;
  wire [31:0] idu2exu_rs2_data;
  wire [31:0] idu2exu_imm;
  wire [1:0]  idu2exu_a_sel;
  wire [1:0]  idu2exu_b_sel;
  wire [10:0] idu2exu_alu_sel;
  wire [3:0]  idu2exu_br_sel;
  wire        idu2memu_is_load;
  wire        idu2memu_is_store;
  wire [4:0]  idu2memu_fmt_sel;
  wire [2:0]  idu2wbu_wb_sel;

  wire        exu2ifu_is_branch_taken;
  wire [31:0] exu2ifu_data;
  wire [31:0] exu2memu_data;
  wire [31:0] exu2memu_rs2_data;
  wire [31:0] exu2wbu_data;

  assign exu2ifu_data = exu2memu_data;
  assign exu2wbu_data = exu2memu_data;


  wire [31:0] memu2wbu_data;
  wire [31:0] memu2biu_daddr;
  wire [3:0]  memu2biu_dwmask;
  wire [31:0] memu2biu_dwdata;


  wire [31:0] wbu2idu_rd_data;


  wire        biu2ifu_halt;
  wire [31:0] biu2ifu_idata;
  wire [31:0] biu2memu_drdata;
  

  wire [11:0] biu2itim_addr;
  wire [31:0] itim2biu_rdata;
  
  wire [11:0] biu2dtim_addr;
  wire [3:0]  biu2dtim_wmask;
  wire [31:0] biu2dtim_wdata;
  wire [31:0] dtim2biu_rdata;
  

  ila_0 u_ila_0 (
   .clk(clk),
   .probe0(ifu2exu_pc),
   .probe1(ifu2idu_inst)
  );
  

  ifu u_ifu (
    .clk(clk),
    .rst(rst),
    .ifu_i_halt(biu2ifu_halt),
    .ifu_i_is_jump(idu2ifu_is_jump),
    .ifu_i_is_branch_taken(exu2ifu_is_branch_taken),
    .ifu_i_pc_target(exu2ifu_data),

    .ifu_o_pc(ifu2exu_pc),
    .ifu_o_inst(ifu2idu_inst),

    .ifu_o_iaddr(ifu2biu_iaddr),
    .ifu_i_idata(biu2ifu_idata)
  );

  idu u_idu (
    .clk(clk),
    .rst(rst),
    .idu_i_inst(ifu2idu_inst),

    .idu_o_is_jump(idu2ifu_is_jump),

    .idu_o_rs1_data(idu2exu_rs1_data),
    .idu_o_rs2_data(idu2exu_rs2_data),
    .idu_o_imm(idu2exu_imm),
    .idu_o_a_sel(idu2exu_a_sel),
    .idu_o_b_sel(idu2exu_b_sel),
    .idu_o_alu_sel(idu2exu_alu_sel),
    .idu_o_br_sel(idu2exu_br_sel),

    .idu_o_is_load(idu2memu_is_load),
    .idu_o_is_store(idu2memu_is_store),
    .idu_o_fmt_sel(idu2memu_fmt_sel),

    .idu_i_rd_data(wbu2idu_rd_data),
    .idu_o_wb_sel(idu2wbu_wb_sel)
  );

  exu u_exu (
    .clk(clk),
    .rst(rst),
    .exu_i_pc(ifu2exu_pc),
    .exu_i_rs1_data(idu2exu_rs1_data),
    .exu_i_rs2_data(idu2exu_rs2_data),
    .exu_i_imm(idu2exu_imm),
    .exu_i_a_sel(idu2exu_a_sel),
    .exu_i_b_sel(idu2exu_b_sel),
    .exu_i_alu_sel(idu2exu_alu_sel),
    .exu_i_br_sel(idu2exu_br_sel),

    .exu_o_exu_data(exu2memu_data),
    .exu_o_rs2_data(exu2memu_rs2_data),
    .exu_o_branch_taken(exu2ifu_is_branch_taken)
  );

  memu u_memu (
    .clk(clk),
    .rst(rst),
    .memu_i_addr(exu2memu_data),
    .memu_i_data(exu2memu_rs2_data),
    .memu_i_is_load(idu2memu_is_load),
    .memu_i_is_store(idu2memu_is_store),
    .memu_i_fmt_sel(idu2memu_fmt_sel),
    .memu_o_data(memu2wbu_data),

    .memu_o_daddr(memu2biu_daddr),
    .memu_o_is_load(memu2biu_is_load),
    .memu_o_is_store(memu2biu_is_store),
    .memu_o_dwmask(memu2biu_dwmask),
    .memu_o_dwdata(memu2biu_dwdata),
    .memu_i_drdata(biu2memu_drdata)
  );

  wbu u_wbu (
    .clk(clk),
    .rst(rst),
    .wbu_i_pc(ifu2wbu_pc),
    .wbu_i_exu_data(exu2wbu_data),
    .wbu_i_memu_data(memu2wbu_data),
    .wbu_i_wb_sel(idu2wbu_wb_sel),
    .wbu_o_wb_data(wbu2idu_rd_data)
  );

  biu u_biu (
    .clk(clk),
    .rst(rst),
    
    .biu_o_halt(biu2ifu_halt),

    .biu_i_iaddr(ifu2biu_iaddr),
    .biu_o_idata(biu2ifu_idata),
    
    .biu_i_daddr(memu2biu_daddr),
    .biu_i_is_load(memu2biu_is_load),
    .biu_i_is_store(memu2biu_is_store),
    .biu_i_dwmask(memu2biu_dwmask),
    .biu_i_dwdata(memu2biu_dwdata),
    .biu_o_drdata(biu2memu_drdata),

    .biu_o_itim_addr(biu2itim_addr),
    .biu_i_itim_rdata(itim2biu_rdata),

    .biu_o_dtim_addr(biu2dtim_addr),
    .biu_o_dtim_wmask(biu2dtim_wmask),
    .biu_o_dtim_wdata(biu2dtim_wdata),
    .biu_i_dtim_rdata(dtim2biu_rdata),
    
    
    .biu_o_tl_a_opcode(core_o_tl_a_opcode),
    .biu_o_tl_a_param(core_o_tl_a_param),
    .biu_o_tl_a_size(core_o_tl_a_size),
    .biu_o_tl_a_source(core_o_tl_a_source),
    .biu_o_tl_a_address(core_o_tl_a_address),
    .biu_o_tl_a_mask(core_o_tl_a_mask),
    .biu_o_tl_a_data(core_o_tl_a_data),
    .biu_o_tl_a_corrupt(core_o_tl_a_corrupt),
    .biu_o_tl_a_valid(core_o_tl_a_valid),
    .biu_i_tl_a_ready(core_i_tl_a_ready),
    
    .biu_i_tl_d_opcode(core_i_tl_d_opcode),
    .biu_i_tl_d_param(core_i_tl_d_param),
    .biu_i_tl_d_size(core_i_tl_d_size),
    .biu_i_tl_d_source(core_i_tl_d_source),
    .biu_i_tl_d_sink(core_i_tl_d_sink),
    .biu_i_tl_d_denied(core_i_tl_d_denied),
    .biu_i_tl_d_data(core_i_tl_d_data),
    .biu_i_tl_d_corrupt(core_i_tl_d_corrupt),
    .biu_i_tl_d_valid(core_i_tl_d_valid),
    .biu_o_tl_d_ready(core_o_tl_d_ready)
  );
  
  itim #(
    .IMEM_HEX(IMEM_HEX),
    .IMEM_BIN(IMEM_BIN)
  ) u_itim (
    .clk(clk),
    .itim_i_addr(biu2itim_addr),
    .itim_o_rdata(itim2biu_rdata)
  );

  dtim u_dtim (
    .clk(clk),
    .rst(rst),
    .dtim_i_addr(biu2dtim_addr),
    .dtim_i_wmask(biu2dtim_wmask),
    .dtim_i_wdata(biu2dtim_wdata),
    .dtim_o_rdata(dtim2biu_rdata)
  );
  

endmodule
