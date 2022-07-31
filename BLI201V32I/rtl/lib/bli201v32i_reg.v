
module register #(
  parameter N = 1
) (
  input clk,
  input [N-1:0] d,
  output reg [N-1:0] q
);
  initial q = {N{1'b0}};
  always @(posedge clk)
    q <= d;
endmodule

module register_rst #(
  parameter N = 1,
  parameter INIT = {N{1'b0}}
) (
  input clk,
  input rst,
  input [N-1:0] d,
  output reg [N-1:0] q
);
  initial q = INIT;
  always @(posedge clk)
    if (!rst) q <= INIT;
    else q <= d;
endmodule

module register_rst_en #(
  parameter N = 1,
  parameter INIT = {N{1'b0}}
) (
  input clk,
  input rst,
  input en,
  input [N-1:0] d,
  output reg [N-1:0] q
);
  initial q = INIT;
  always @(posedge clk)
    if (!rst) q <= INIT;
    else if (en) q <= d;
endmodule
