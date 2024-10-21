// Copyright (C) 2024
//    Peter Herrmann
//
// Modified from existing source from Ben Marshall, with the following license:
// 
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
// module: tb_checker_xperm8_rv32
//
//  Re-usable checker for the 32-bit xperm8 instructions
//
module tb_checker_xperm8_rv32 (

input  wire [31:0] rs1,
input  wire [31:0] rs2,

output wire [31:0] rd

);

// Calculate the lut.
wire [7:0] xperm8_rv32_lut [3:0];

genvar i;
generate for(i = 0; i < 4; i = i + 1) begin
    assign xperm8_rv32_lut[i] = rs2[8*i+:8];
end endgenerate

// Calculate the nibble values for the output
assign rd[8*0+:8] = xperm8_rv32_lut[rs1[8*0+:2]];
assign rd[8*1+:8] = xperm8_rv32_lut[rs1[8*1+:2]];
assign rd[8*2+:8] = xperm8_rv32_lut[rs1[8*2+:2]];
assign rd[8*3+:8] = xperm8_rv32_lut[rs1[8*3+:2]];

endmodule
