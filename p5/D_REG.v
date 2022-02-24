`timescale 1ns/1ps
`include "macro.v"

module D_REG (
    input wire [31:0] Instr_in,
    input wire [31:0] pc_in,
    input wire D_REG_Wr,
    input wire clk,
    input wire reset,
    output reg [31:0] Instr_out,
    output reg [31:0] pc_out
);
    always @(posedge clk) begin
        if (reset) begin
            Instr_out <= 0;
            pc_out <= 0;
        end
        else if (D_REG_Wr) begin
            Instr_out <= Instr_in;
            pc_out <= pc_in;
        end
    end
endmodule //D_REG