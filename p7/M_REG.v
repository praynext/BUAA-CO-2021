`timescale 1ns/1ps
`include "macro.v"

module M_REG (
    input wire Req,
    input wire clk,
    input wire reset,
    input wire M_REG_Wr,
    input wire [31:0] Instr_in,
    input wire [31:0] pc_in,
    input wire [31:0] C_in,
    input wire [31:0] EXTout_in,
    input wire [31:0] RD2_in,
    input wire [31:0] HILO_in,
    input wire Delaycheck_in,
    input wire [4:0] ExcCode_in,
    input wire ExcDMOv_in,
    output reg [31:0] Instr_out,
    output reg [31:0] pc_out,
    output reg [31:0] C_out,
    output reg [31:0] EXTout_out,
    output reg [31:0] RD2_out,
    output reg [31:0] HILO_out,
    output reg Delaycheck_out,
    output reg [4:0] ExcCode_out,
    output reg ExcDMOv_out
);
    always @(posedge clk) begin
        if (Req || reset) begin
            Instr_out <= 0;
            pc_out <= Req ? 32'h0000_4180 : 0;
            C_out <= 0;
            EXTout_out <= 0;
            RD2_out <= 0;
            HILO_out <= 0;
            Delaycheck_out <= 0;
            ExcCode_out <= 0;
            ExcDMOv_out <= 0;
        end
        else if (M_REG_Wr) begin
            Instr_out <= Instr_in;
            pc_out <= pc_in;
            C_out <= C_in;
            EXTout_out <= EXTout_in;
            RD2_out <= RD2_in;
            HILO_out <= HILO_in;
            Delaycheck_out <= Delaycheck_in;
            ExcCode_out <= ExcCode_in;
            ExcDMOv_out <= ExcDMOv_in;
        end
    end
endmodule //M_REG