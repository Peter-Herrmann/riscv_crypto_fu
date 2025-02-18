// Copyright (C) 2024
//    Peter Herrmann
//
// Modified from existing source from Ben Marshall, with the following license:
// 
// Copyright (C) 2020 
//    SCARV Project  <info@scarv.org>
//    Ben Marshall   <ben.marshall@bristol.ac.uk>
// 
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
// 
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
// IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

//
// module: riscv_crypto_fu_xperm
//
//  Implements the XPERM instructions for the RISC-V cryptography extension Zbkx.
//
//  The following table shows which instructions are implemented
//  based on the selected value of XLEN.
//
//  Instruction     | XLEN=32 | XLEN=64 
//  ----------------|---------|---------
//   xperm4         |    x    |    x    
//   xperm8         |    x    |    x    
//
module riscv_crypto_fu_xperm #(
parameter XLEN          = 64  // Must be one of: 32, 64.
)(

input  wire             g_clk           , // Global clock
input  wire             g_resetn        , // Synchronous active low reset.

input  wire             valid           , // Inputs valid.
input  wire [ XLEN-1:0] rs1             , // Source register 1
input  wire [ XLEN-1:0] rs2             , // Source register 2

input  wire             op_xperm4       , // Crossbar Permutation (nibbles) Instruction
input  wire             op_xperm8       , // Crossbar Permutation (bytes) Instruction

output wire             ready           , // Outputs ready.
output wire [ XLEN-1:0] rd                // Result.

);


//
// Local/internal parameters and useful defines:
// ------------------------------------------------------------

localparam XL   = XLEN -  1  ;
localparam RV32 = XLEN == 32 ;
localparam RV64 = XLEN == 64 ;

localparam NIBBLES = XLEN / 4;
localparam BYTES   = XLEN / 8;

//
// Instruction logic
// ------------------------------------------------------------

// Single cycle instructions.
assign ready = valid;

// Easily indexable access to the LUT.
wire [3:0] xperm4_lut [NIBBLES-1:0];
wire [7:0] xperm8_lut [BYTES-1:0];

wire [ XLEN-1:0] xperm8_rd, xperm4_rd;


// XPERM4: unpack nibbles from RS2. Works for RV32 and RV64.
genvar n;
for(n = 0; n < NIBBLES; n = n + 1) begin
    
    // Pull out each nibble of rs2.
    assign xperm4_lut[n] = rs2[4*n+:4];

    if (RV32) begin : rv32_xperm4               // RV32 XPERM4
        wire [2:0] lut_in;
        wire [3:0] lut_out;
        assign lut_in            = rs1[4*n+:3];
        assign lut_out           = xperm4_lut[lut_in];
        assign xperm4_rd[n*4+:4] = lut_out;

    end else if(RV64) begin : rv64_xperm4      // RV64 XPERM4
        wire [3:0] lut_in;
        assign lut_in            = rs1[4*n+:4];
        assign xperm4_rd[n*4+:4] = xperm4_lut[lut_in];

    end

end


// XPERM8: unpack bytes from RS2. Works for RV32 and RV64.
genvar b;
for(b = 0; b < BYTES; b = b + 1) begin
    
    // Pull out each nibble of rs2.
    assign xperm8_lut[b] = rs2[8*b+:8];

    if (RV32) begin : rv32_xperm8               // RV32 XPERM8
        wire [1:0] lut_in;
        wire [7:0] lut_out;
        assign lut_in            = rs1[8*b+:2];
        assign lut_out           = xperm8_lut[lut_in];
        assign xperm8_rd[b*8+:8] = lut_out;

    end else if(RV64) begin : rv64_xperm8      // RV64 XPERM8
        wire [2:0] lut_in;
        assign lut_in            = rs1[8*b+:3];
        assign xperm8_rd[b*8+:8] = xperm8_lut[lut_in];

    end

end


assign rd = op_xperm8 ? xperm8_rd : xperm4_rd;


endmodule
