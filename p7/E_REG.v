`timescale 1ns/1ps
`include "macro.v"

module E_REG (
    input wire Req,
    input wire stall,
    input wire [31:0] RD1_in,
    input wire [31:0] RD2_in,
    input wire [31:0] Instr_in,
    input wire [31:0] EXT_in,
    input wire [31:0] pc_in,
    input wire Delaycheck_in,
    input wire [4:0] ExcCode_in,
    input wire clk,
    input wire reset,
    input wire E_REG_Wr,
    output reg [31:0] Instr_out,
    output reg [31:0] EXT_out,
    output reg [31:0] pc_out,
    output reg [31:0] RD1_out,
    output reg [31:0] RD2_out,
    output reg Delaycheck_out,
    output reg [4:0] ExcCode_out
);
    always @(posedge clk) begin
        if (Req || stall || reset) begin
            Instr_out <= 0;
            EXT_out <= 0;
            pc_out <= stall ? pc_in : (Req ? 32'h0000_4180 : 0);
            RD1_out <= 0;
            RD2_out <= 0;
            Delaycheck_out <= stall ? Delaycheck_in : 0;
            ExcCode_out <= 0;
        end
        else if (E_REG_Wr) begin
            Instr_out <= Instr_in;
            EXT_out <= EXT_in;
            pc_out <= pc_in;
            RD1_out <= RD1_in;
            RD2_out <= RD2_in;
            Delaycheck_out <= Delaycheck_in;
            ExcCode_out <= ExcCode_in;
        end
    end
endmodule //E_REG