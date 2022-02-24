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
                (ALUOp == `ALU_and) ? (A & B) :
                (ALUOp == `ALU_or) ? (A | B) :
                (ALUOp == `ALU_xor) ? (A ^ B) :
                (ALUOp == `ALU_nor) ? ~(A | B) :
                (ALUOp == `ALU_sll) ? (B << A) :
                (ALUOp == `ALU_srl) ? (B >> A) :
                (ALUOp == `ALU_sra) ? ($signed($signed(B) >>> A)) :
                (ALUOp == `ALU_slt) ? ($signed(A) < $signed(B) ? 32'b1 : 32'b0) :
                (ALUOp == `ALU_sltu) ? (A < B) :
                (ALUOp == `ALU_lui) ? (B << 16) :
                32'h0000_0000;
endmodule //E_ALU