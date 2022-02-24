`timescale 1ns/1ps
`include "macro.v"

module E_HILO (
    input wire Req,
    input wire clk,
    input wire reset,
    input wire [31:0] RD1,
    input wire [31:0] RD2,
    input wire [3:0] HILOOp,
    output wire HILObusy,
    output wire [31:0] HILOout
);
    integer cycle = 0;
    reg busy;
    reg [31:0] hi, lo, temphi, templo;
    wire mult = (HILOOp == `HILO_mult);
    wire multu = (HILOOp == `HILO_multu);
    wire div = (HILOOp == `HILO_div);
    wire divu = (HILOOp == `HILO_divu);
    wire mfhi = (HILOOp == `HILO_mfhi);
    wire mflo = (HILOOp == `HILO_mflo);
    wire mthi = (HILOOp == `HILO_mthi);
    wire mtlo = (HILOOp == `HILO_mtlo);
    wire start = mult | multu | div | divu;
    initial begin
        cycle = 0;
        busy = 0;
        hi = 0;
        lo = 0;
    end
    always @(posedge clk) begin
        if (reset) begin
            cycle = 0;
            busy = 0;
            hi = 0;
            lo = 0;
        end
        else if (!Req) begin
            if (cycle == 0) begin
                if (mthi) begin
                    hi <= RD1;
                end
                else if (mtlo) begin
                    lo <= RD1;
                end
                else if (mult) begin
                    busy <= 1;
                    cycle <= 5;
                    {temphi, templo} <= $signed(RD1) * $signed(RD2);
                end
                else if (multu) begin
                    busy <= 1;
                    cycle <= 5;
                    {temphi, templo} <= RD1 * RD2;
                end
                else if (div) begin
                    busy <= 1;
                    cycle <= 10;
                    temphi <= $signed(RD1) % $signed(RD2);
                    templo <= $signed(RD1) / $signed(RD2);
                end
                else if (divu) begin
                    busy <= 1;
                    cycle <= 10;
                    temphi <= RD1 % RD2;
                    templo <= RD1 / RD2;
                end
            end
            else if (cycle == 1) begin
                cycle <= 0;
                busy <= 0;
                hi <= temphi;
                lo <= templo;
            end
            else begin
                cycle <= cycle - 1;
            end
        end
    end
    assign HILObusy = start | busy;
    assign HILOout = mfhi ? hi :
                    mflo ? lo :
                    0;
endmodule //E_HILO