`timescale 1ns/1ps
`include "macro.v"
`define wdata memory[Addr[13:2]]
`define hdata `wdata[15 + 16 * Addr[1] -:16]
`define bdata `wdata[7 + 8 * Addr[1:0] -:8]

module M_DM (
    input wire [31:0] pc,
    input wire [31:0] Addr,
    input wire [31:0] WD,
    input wire [2:0] DMOp,
    input wire clk,
    input wire reset,
    input wire DMWr,
    output wire [31:0] RD
);
    function [31:0] sign_ext16;
        input [15:0] inputImm;
        begin
            sign_ext16 = {{16{inputImm[15]}}, inputImm};
        end
    endfunction

    function [31:0] unsign_ext16;
        input [15:0] inputImm;
        begin
            unsign_ext16 = {{16{1'b0}}, inputImm};
        end
    endfunction

    function [31:0] sign_ext8;
        input [7:0] inputImm;
        begin
            sign_ext8 = {{24{inputImm[7]}}, inputImm};
        end
    endfunction

    function [31:0] unsign_ext8;
        input [7:0] inputImm;
        begin
            unsign_ext8 = {{24{1'b0}}, inputImm};
        end
    endfunction

    function [31:0] H_data;
        input [31:0] inputdata;
        input [31:0] worddata;
        begin
            H_data = worddata;
            H_data[15 + 16 * Addr[1] -:16] = worddata[15:0];
        end
    endfunction

    function [31:0] B_data;
        input [31:0] inputdata;
        input [31:0] worddata;
        begin
            B_data = worddata;
            B_data[7 + 8 * Addr[1:0] -:8] = worddata[7:0];
        end
    endfunction

    reg [31:0] memory [3071:0];
    integer i;
    initial begin
        for (i=0; i<3072; i=i+1) begin
            memory[i] <= 0;
        end
    end
    always @(posedge clk) begin
        if (reset) begin
            for (i=0; i<3072; i=i+1) begin
                memory[i] <= 0;
            end
        end
        else if (DMWr) begin
            if (DMOp == `DM_w) begin
                `wdata <= WD;
                $display("%d@%h: *%h <= %h", $time, pc, Addr, WD);
            end
            else if (DMOp == `DM_h) begin
                `hdata <= WD[15:0];
                $display("%d@%h: *%h <= %h", $time, pc, {Addr[31:2], 2'b00}, H_data(WD, `wdata));
            end
            else if (DMOp == `DM_b) begin
                `bdata <= WD[7:0];
                $display("%d@%h: *%h <= %h", $time, pc, {Addr[31:2], 2'b00}, B_data(WD, `wdata));
            end
        end
    end
    assign RD = (DMOp == `DM_w) ? `wdata :
                (DMOp == `DM_h) ? sign_ext16(`hdata) :
                (DMOp == `DM_hu) ? unsign_ext16(`hdata) :
                (DMOp == `DM_b) ? sign_ext8(`bdata) :
                (DMOp == `DM_bu) ? unsign_ext8(`bdata) :
                32'h0000_0000;
endmodule //M_DM