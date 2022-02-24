`timescale 1ns/1ps
`include "macro.v"

module IFU (
    input wire [31:0] npc,
    input wire clk,
    input wire reset,
    output reg [31:0] pc,
    output wire [31:0] Instr,
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire [4:0] rd,
    output wire [15:0] Imm16,
    output wire [25:0] Imm26,
    output wire [5:0] opcode,
    output wire [5:0] funct,
    output wire [4:0] shamt
);
    reg [31:0] IM [1023:0];
    initial begin
        pc = 32'h0000_3000;
        $readmemh("code.txt", IM, 0, 1023);
    end
    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'h0000_3000;
        end
        else begin
            pc <= npc;
        end
    end
    assign Instr = IM[pc[11:2]];
    assign rs = Instr[25:21];
    assign rt = Instr[20:16];
    assign rd = Instr[15:11];
    assign shamt = Instr[10:6];
    assign opcode = Instr[31:26];
    assign funct = Instr[5:0];
    assign Imm16 = Instr[15:0];
    assign Imm26 = Instr[25:0];
endmodule //IFU