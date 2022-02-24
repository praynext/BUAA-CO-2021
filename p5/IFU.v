`timescale 1ns/1ps
`include "macro.v"

module IFU (
    input wire [31:0] npc,
    input wire clk,
    input wire reset,
    input wire IFUWr,
    output wire [31:0] Instr,
    output reg [31:0] pc
);
    reg [31:0] IM [4095:0];
    initial begin
        pc = 32'h0000_3000;
        $readmemh("code.txt", IM, 0, 4095);
    end
    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'h0000_3000;
        end
        else if (IFUWr) begin
            pc <= npc;
        end
    end
    assign Instr = IM[(pc-32'h0000_3000)>>2];
endmodule //IFU