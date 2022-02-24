`timescale 1ns/1ps
`include "macro.v"

module STALLCTRL (
    input wire [31:0] D_Instr,
    input wire [31:0] E_Instr,
    input wire [31:0] M_Instr,
    output wire stall
);
    //D_stage
    wire [4:0] D_rs;
    wire [4:0] D_rt;
    wire D_rtype, D_itype, D_load, D_store, D_j_reg, D_branch;
    CTRL D_STALLCTRL (
        .Instr(D_Instr),
        .rs(D_rs),
        .rt(D_rt),
        ._rtype(D_rtype),
        ._itype(D_itype),
        ._load(D_load),
        ._store(D_store),
        ._j_reg(D_j_reg),
        ._branch(D_branch)
    );
    wire [1:0] Tuse_RS = (D_branch | D_j_reg) ? 2'b00 :
                        (D_rtype | D_itype | D_load | D_store) ? 2'b01 :
                        2'b11;
    wire [1:0] Tuse_RT = (D_branch) ? 2'b00 :
                        (D_rtype) ? 2'b01 :
                        (D_store) ? 2'b10 :
                        2'b11;
    //E_stage
    wire [4:0] E_RegDst;
    wire E_rtype, E_itype, E_load;
    CTRL E_STALLCTRL (
        .Instr(E_Instr),
        ._rtype(E_rtype),
        ._itype(E_itype),
        ._load(E_load),
        .RegDst(E_RegDst)
    );
    wire [1:0] Tnew_E = (E_rtype | E_itype) ? 2'b01 :
                        (E_load) ? 2'b10 :
                        2'b00;
    //M_stage
    wire [4:0] M_RegDst;
    wire M_rtype, M_itype, M_load;
    CTRL M_STALLCTRL (
        .Instr(M_Instr),
        ._rtype(M_rtype),
        ._itype(M_itype),
        ._load(M_load),
        .RegDst(M_RegDst)
    );
    wire [1:0] Tnew_M = (M_load) ? 2'b01 : 2'b00;
    //stall
    wire E_stall_rs = (Tuse_RS < Tnew_E) && (D_rs) && (D_rs==E_RegDst);
    wire M_stall_rs = (Tuse_RS < Tnew_M) && (D_rs) && (D_rs==M_RegDst);
    wire stall_rs = E_stall_rs || M_stall_rs;

    wire E_stall_rt = (Tuse_RT < Tnew_E) && (D_rt) && (D_rt==E_RegDst);
    wire M_stall_rt = (Tuse_RT < Tnew_M) && (D_rt) && (D_rt==M_RegDst);
    wire stall_rt = E_stall_rt || M_stall_rt;

    assign stall = stall_rs || stall_rt;
endmodule //STALLCTRL