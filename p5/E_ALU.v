`timescale 1ns/1ps
`include "macro.v"

module E_ALU (
    input wire [3:0] ALUOp,
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] C
);
    assign C = (ALUOp == `ALU_add) ? (A + B) :
                (ALUOp == `ALU_sub) ? (A - B) :
                (ALUOp == `ALU_or) ? (A | B) :
                (ALUOp == `ALU_lui) ? (B << 16) :
                (ALUOp == `ALU_sll) ? (B << A) :
                32'h0000_0000;
endmodule //E_ALU