`timescale 1ns/1ps
`include "macro.v"

module IFU (
    input wire [31:0] npc,
    input wire clk,
    input wire reset,
    input wire IFUWr,
    output reg [31:0] pc
);
    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'h0000_3000;
        end
        else if (IFUWr) begin
            pc <= npc;
        end
    end
endmodule //IFU