`timescale 1ns/1ps
`include "macro.v"

module W_REG (
    input wire Req,
    input wire clk,
    input wire reset,
    input wire W_REG_Wr,
    input wire [31:0] Instr_in,
    input wire [31:0] pc_in,
    input wire [31:0] C_in,
    input wire [31:0] RD_in,
    input wire [31:0] EXTout_in,
    input wire [31:0] HILO_in,
    input wire [31:0] CP0_in,
    output reg [31:0] Instr_out,
    output reg [31:0] pc_out,
    output reg [31:0] C_out,
    output reg [31:0] RD_out,
    output reg [31:0] EXTout_out,
    output reg [31:0] HILO_out,
    output reg [31:0] CP0_out
);
    always @(posedge clk) begin
        if (Req || reset) begin
            Instr_out <= 0;
            pc_out <= Req ? 32'h0000_4180 : 0;
            C_out <= 0;
            RD_out <= 0;
            EXTout_out <= 0;
            HILO_out <= 0;
            CP0_out <= 0;
        end
        else if (W_REG_Wr) begin
            Instr_out <= Instr_in;
            pc_out <= pc_in;
            C_out <= C_in;
            RD_out <= RD_in;
            EXTout_out <= EXTout_in;
            HILO_out <= HILO_in;
            CP0_out <= CP0_in;
        end
    end
endmodule //W_REG