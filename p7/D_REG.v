`timescale 1ns/1ps
`include "macro.v"

module D_REG (
    input wire Req,
    input wire [31:0] Instr_in,
    input wire [31:0] pc_in,
    input wire Delaycheck_in,
    input wire [4:0] ExcCode_in,
    input wire D_REG_Wr,
    input wire clk,
    input wire reset,
    output reg [31:0] Instr_out,
    output reg [31:0] pc_out,
    output reg Delaycheck_out,
    output reg [4:0] ExcCode_out
);
    always @(posedge clk) begin
        if (Req || reset) begin
            Instr_out <= 0;
            pc_out <= Req ? 32'h0000_4180 : 32'd0;
            Delaycheck_out <= 0;
            ExcCode_out <= 0;
        end
        else if (D_REG_Wr) begin
            Instr_out <= Instr_in;
            pc_out <= pc_in;
            Delaycheck_out <= Delaycheck_in;
            ExcCode_out <= ExcCode_out;
        end
    end
endmodule //D_REG