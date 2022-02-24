`timescale 1ns/1ps
`include "macro.v"
`include "D_CMP.v"
`include "D_EXT.v"
`include "D_GRF.v"
`include "D_NPC.v"
`include "D_REG.v"
`include "E_ALU.v"
`include "E_REG.v"
`include "M_DM.v"
`include "M_REG.v"
`include "W_REG.v"
`include "IFU.v"
`include "CTRL.v"
`include "STALLCTRL.v"

module mips (
    input wire clk,
    input wire reset
);
    wire stall;
    wire [31:0] F_Instr, D_Instr, E_Instr, M_Instr, W_Instr;
    STALLCTRL stallctrl (
        .D_Instr(D_Instr),
        .E_Instr(E_Instr),
        .M_Instr(M_Instr),
        .stall(stall)
    );
    wire [31:0] E_WD, M_WD, W_WD, E_pc, M_pc, W_pc, M_C, W_C, W_RD;
    wire [4:0] E_RegDst, M_RegDst, W_RegDst;
    wire [1:0] E_MemtoReg, M_MemtoReg, W_MemtoReg;
    assign E_WD = (E_MemtoReg == `MemtoReg_pc8) ? (E_pc + 8) :
                    0;
    assign M_WD = (M_MemtoReg == `MemtoReg_ALU) ? (M_C) :
                    (M_MemtoReg == `MemtoReg_pc8) ? (M_pc + 8) :
                    0;
    assign W_WD = (W_MemtoReg == `MemtoReg_ALU) ? (W_C) :
                    (W_MemtoReg == `MemtoReg_DM) ? (W_RD) :
                    (W_MemtoReg == `MemtoReg_pc8) ? (W_pc + 8) :
                    0;

    //F_stage
    wire [31:0] F_pc, npc;
    wire F_IFUWr = !stall;
    IFU ifu (
        .npc(npc),
        .clk(clk),
        .reset(reset),
        .IFUWr(F_IFUWr),
        .Instr(F_Instr),
        .pc(F_pc)
    );


    //D_stage
    wire [31:0] D_pc;
    wire D_REG_Wr = !stall;
    wire D_REG_reset = 1'b0;
    D_REG D_reg (
        .Instr_in(F_Instr),
        .pc_in(F_pc),
        .D_REG_Wr(D_REG_Wr),
        .clk(clk),
        .reset(reset || D_REG_reset),
        .Instr_out(D_Instr),
        .pc_out(D_pc)
    );


    wire [4:0] D_rs, D_rt;
    wire [15:0] D_Imm16;
    wire [25:0] D_Imm26;
    wire D_EXTOp;
    wire [2:0] D_CMPOp, D_NPCOp;
    CTRL D_CTRL (
        .Instr(D_Instr),
        .rs(D_rs),
        .rt(D_rt),
        .Imm16(D_Imm16),
        .Imm26(D_Imm26),
        .EXTOp(D_EXTOp),
        .CMPOp(D_CMPOp),
        .NPCOp(D_NPCOp)
    );


    wire [31:0] D_RD1, D_RD2;
    wire W_RFWr;
    D_GRF D_grf (
        .pc(W_pc),
        .A1(D_rs),
        .A2(D_rt),
        .A3(W_RegDst),
        .WD(W_WD),
        .clk(clk),
        .reset(reset),
        .RFWr(W_RFWr),
        .RD1(D_RD1),
        .RD2(D_RD2)
    );


    wire [31:0]  D_EXTout;
    D_EXT D_ext (
        .Imm16(D_Imm16),
        .EXTOp(D_EXTOp),
        .EXTout(D_EXTout)
    );


    //D_Forward
    wire D_zerocheck;
    wire [31:0] D_FWD_RD1 = (D_rs == 0) ? 0 :
                            (D_rs == E_RegDst) ? E_WD :
                            (D_rs == M_RegDst) ? M_WD :
                            D_RD1;
    wire [31:0] D_FWD_RD2 = (D_rt == 0) ? 0 :
                            (D_rt == E_RegDst) ? E_WD :
                            (D_rt == M_RegDst) ? M_WD :
                            D_RD2;
    D_CMP D_cmp (
        .RD1(D_FWD_RD1),
        .RD2(D_FWD_RD2),
        .CMPOp(D_CMPOp),
        .zerocheck(D_zerocheck)
    );


    D_NPC D_npc (
        .D_pc(D_pc),
        .F_pc(F_pc),
        .Imm26(D_Imm26),
        .ra(D_FWD_RD1),
        .NPCOp(D_NPCOp),
        .zerocheck(D_zerocheck),
        .npc(npc)
    );


    //E_stage
    wire [31:0] E_EXTout, E_RD1, E_RD2;
    wire E_REG_Wr = 1'b1;
    wire E_REG_reset = stall;
    E_REG E_reg (
        .RD1_in(D_FWD_RD1),
        .RD2_in(D_FWD_RD2),
        .Instr_in(D_Instr),
        .EXT_in(D_EXTout),
        .pc_in(D_pc),
        .clk(clk),
        .reset(reset || E_REG_reset),
        .E_REG_Wr(E_REG_Wr),
        .Instr_out(E_Instr),
        .EXT_out(E_EXTout),
        .pc_out(E_pc),
        .RD1_out(E_RD1),
        .RD2_out(E_RD2)
    );


    wire [3:0] E_ALUOp;
    wire E_ALUASrc, E_ALUBSrc;
    wire [4:0] E_rs, E_rt;
    CTRL E_CTRL (
        .Instr(E_Instr),
        .rs(E_rs),
        .rt(E_rt),
        .ALUOp(E_ALUOp),
        .ALUASrc(E_ALUASrc),
        .ALUBSrc(E_ALUBSrc),
        .RegDst(E_RegDst),
        .MemtoReg(E_MemtoReg)
    );


    //E_Forward
    wire [31:0] E_A, E_B, E_C; 
    wire [31:0] E_FWD_RD1 = (E_rs == 0) ? 0 :
                            (E_rs == M_RegDst) ? M_WD :
                            (E_rs == W_RegDst) ? W_WD :
                            E_RD1;
    wire [31:0] E_FWD_RD2 = (E_rt == 0) ? 0 :
                            (E_rt == M_RegDst) ? M_WD :
                            (E_rt == W_RegDst) ? W_WD :
                            E_RD2;
    assign E_A = (E_ALUASrc == `ALUASrc_rs) ? E_FWD_RD1 :
                (E_ALUASrc == `ALUASrc_shamt) ? {27'b0, E_Instr[10:6]} :
                0;
    assign E_B = (E_ALUBSrc == `ALUBSrc_rt) ? E_FWD_RD2 :
                (E_ALUBSrc == `ALUBSrc_EXT) ? E_EXTout :
                0;
    E_ALU E_alu (
        .ALUOp(E_ALUOp),
        .A(E_A),
        .B(E_B),
        .C(E_C)
    );


    //M_stage
    wire [31:0] M_EXTout, M_RD2;
    wire M_REG_Wr = 1'b1;
    wire M_REG_reset = 1'b0;
    M_REG M_reg (
        .clk(clk),
        .reset(reset || M_REG_reset),
        .M_REG_Wr(M_REG_Wr),
        .Instr_in(E_Instr),
        .pc_in(E_pc),
        .C_in(E_C),
        .EXTout_in(E_EXTout),
        .RD2_in(E_FWD_RD2),
        .Instr_out(M_Instr),
        .pc_out(M_pc),
        .C_out(M_C),
        .EXTout_out(M_EXTout),
        .RD2_out(M_RD2)
    );


    wire [4:0] M_rt;
    wire [2:0] M_DMOp;
    wire M_DMWr;
    CTRL M_CTRL (
        .Instr(M_Instr),
        .rt(M_rt),
        .DMOp(M_DMOp),
        .DMWr(M_DMWr),
        .RegDst(M_RegDst),
        .MemtoReg(M_MemtoReg)
    );


    //M_Forward
    wire [31:0] M_RD;
    wire [31:0] M_FWD_RD2 = (M_rt == 0) ? 0 :
                            (M_rt == W_RegDst) ? W_WD :
                            M_RD2;
    M_DM M_dm (
        .pc(M_pc),
        .Addr(M_C),
        .WD(M_FWD_RD2),
        .DMOp(M_DMOp),
        .clk(clk),
        .reset(reset),
        .DMWr(M_DMWr),
        .RD(M_RD)
    );


    //W_stage
    wire W_REG_Wr = 1'b1;
    wire W_REG_reset = 1'b0;
    wire [31:0] W_EXTout;
    W_REG W_reg (
        .clk(clk),
        .reset(reset || W_REG_reset),
        .W_REG_Wr(W_REG_Wr),
        .Instr_in(M_Instr),
        .pc_in(M_pc),
        .C_in(M_C),
        .RD_in(M_RD),
        .EXTout_in(M_EXTout),
        .Instr_out(W_Instr),
        .pc_out(W_pc),
        .C_out(W_C),
        .RD_out(W_RD),
        .EXTout_out(W_EXTout)
    );


    CTRL W_CTRL (
        .Instr(W_Instr),
        .RegDst(W_RegDst),
        .RFWr(W_RFWr),
        .MemtoReg(W_MemtoReg)
    );
endmodule //mips