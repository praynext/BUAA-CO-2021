`timescale 1ns/1ps
`include "macro.v"

module D_GRF (
    input wire [31:0] pc,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [4:0] A3,
    input wire [31:0] WD,
    input wire clk,
    input wire reset,
    input wire RFWr,
    output wire [31:0] RD1,
    output wire [31:0] RD2
);
    reg [31:0] grf [31:0];
    integer i;
    initial begin
        for (i=0; i<32; i=i+1) begin
            grf[i] = 0;
        end
    end
    always @(posedge clk) begin
        if (reset) begin
            for (i=0; i<32; i=i+1) begin
                grf[i] <= 0;
            end
        end
        else if (RFWr) begin
            if (A3) begin
                grf[A3] <= WD;
                $display("%d@%h: $%d <= %h", $time, pc, A3, WD);
            end
        end
    end
    assign RD1 = ((A3==A1) && A3 && RFWr) ? WD : grf[A1];
    assign RD2 = ((A3==A2) && A3 && RFWr) ? WD : grf[A2];
endmodule //D_GRF