`timescale 1ns/1ps
`include "macro.v"

module D_EXT (
    input wire [15:0] Imm16,
    input wire EXTOp,
    output wire [31:0] EXTout
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

    assign EXTout = EXTOp ? sign_ext16(Imm16) : unsign_ext16(Imm16);
endmodule //D_EXT