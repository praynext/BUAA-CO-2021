`timescale 1ns/1ps
`include "macro.v"

module CMP (
    input wire [31:0] RD1,
    input wire [31:0] RD2,
    input wire [1:0] CMPOp,
    output wire zerocheck
);
    wire eq = (RD1 == RD2);
    wire ne = !eq;
    wire gtz = ($signed(RD1) > 0);
    wire ltz = ($signed(RD1) < 0);
    wire eqz = (RD1 == 0);
    assign zerocheck = ((CMPOp == `CMP_beq) && eq);
endmodule //CMP