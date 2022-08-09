/** 
 * tl_defines.h
 *
 * This file defines the TileLink configuration parameters and some constants
 * according to the TileLink Specification 1.8.1
 *
 * @ref https://starfivetech.com/uploads/tilelink_spec_1.8.1.pdf
 */

/**
 * TileLink per-link parameters.
 */
`define TL_PARAM_WIDTH_Z              3
`define TL_PARAM_WIDTH_O              1
`define TL_PARAM_WIDTH_I              1
`define TL_PARAM_WIDTH_A              32
`define TL_PARAM_WIDTH_W              4
`define TL_PARAM_WIDTH_8W             (`TL_PARAM_WIDTH_W * 8)


/**
 * TileLink TL-Ux buses
 */
`define TL_A_WIDTH_OPCODE             3
`define TL_A_WIDTH_PARAM              3
`define TL_A_WIDTH_SIZE               `TL_PARAM_WIDTH_Z
`define TL_A_WIDTH_SOURCE             `TL_PARAM_WIDTH_O
`define TL_A_WIDTH_ADDRESS            `TL_PARAM_WIDTH_A
`define TL_A_WIDTH_MASK               `TL_PARAM_WIDTH_W
`define TL_A_WIDTH_DATA               `TL_PARAM_WIDTH_8W
`define TL_A_WIDTH_CORRUPT            1

`define TL_D_WIDTH_OPCODE             3
`define TL_D_WIDTH_PARAM              2
`define TL_D_WIDTH_SIZE               `TL_PARAM_WIDTH_Z
`define TL_D_WIDTH_SOURCE             `TL_PARAM_WIDTH_O
`define TL_D_WIDTH_SINK               `TL_PARAM_WIDTH_I
`define TL_D_WIDTH_DENIED             1
`define TL_D_WIDTH_DATA               `TL_PARAM_WIDTH_8W
`define TL_D_WIDTH_CORRUPT            1


/**
 * TileLink TL-UL constants
 */
`define TL_A_MSG_GET_OPCODE              `TL_A_WIDTH_OPCODE'h4
`define TL_A_MSG_GET_PARAM                `TL_A_WIDTH_PARAM'h0

`define TL_A_MSG_PUTFULLDATA_OPCODE      `TL_A_WIDTH_OPCODE'h0
`define TL_A_MSG_PUTFULLDATA_PARAM        `TL_A_WIDTH_PARAM'h0

`define TL_A_MSG_PUTPARTIALDATA_OPCODE   `TL_A_WIDTH_OPCODE'h1
`define TL_A_MSG_PUTPARTIALDATA_PARAM     `TL_A_WIDTH_PARAM'h0


`define TL_D_MSG_ACCESSACK_OPCODE        `TL_D_WIDTH_OPCODE'h0
`define TL_D_MSG_ACCESSACK_PARAM          `TL_D_WIDTH_PARAM'h0

`define TL_D_MSG_ACCESSACKDATA_OPCODE    `TL_D_WIDTH_OPCODE'h1
`define TL_D_MSG_ACCESSACKDATA_PARAM      `TL_D_WIDTH_PARAM'h0
