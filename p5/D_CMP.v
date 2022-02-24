`timescale 1ns/1ps
`include "macro.v"

module D_CMP (
    input wire [31:0] RD1,
    input wire [31:0] RD2,
    input wire [2:0] CMPOp,
    output wire zerocheck
);
    wire eq = (RD1==RD2);
    wire ne = !eq;
    wire gtz = ($signed(RD1) > 0);
    wire ltz = ($signed(RD1) < 0);
    wire eqz = (RD1 == 0);
    assign zerocheck = ((CMPOp == `CMP_beq) && eq) ||
                        ((CMPOp == `CMP_bne) && ne) ||
                        ((CMPOp == `CMP_bgtz) && gtz) ||
                        ((CMPOp == `CMP_bltz) && ltz) ||
                        ((CMPOp == `CMP_bgez) && (gtz || eqz)) ||
                        ((CMPOp == `CMP_blez) && (ltz || eqz));
endmodule //D_CMP