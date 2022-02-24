`timescale 1ns/1ps
`include "macro.v"
`include "D_CMP.v"
`include "D_EXT.v"
`include "D_GRF.v"
`include "D_NPC.v"
`include "D_REG.v"
`include "E_ALU.v"
`include "E_HILO.v"
`include "E_REG.v"
`include "M_REG.v"
`include "W_REG.v"
`include "IFU.v"
`include "CTRL.v"
`include "STALLCTRL.v"

module mips (
    input wire clk,
    input wire reset,
    input wire [31:0] i_inst_rdata,
    input wire [31:0] m_data_rdata,
    output wire [31:0] i_inst_addr,
    output wire [31:0] m_data_addr,
    output wire [31:0] m_data_wdata,
    output wire [3:0] m_data_byteen,
    output wire [31:0] m_inst_addr,
    output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    output wire [31:0] w_inst_addr
);
    wire E_HILObusy, stall;
    wire [31:0] F_Instr, D_Instr, E_Instr, M_Instr, W_Instr;
    STALLCTRL stallctrl (
        .D_Instr(D_Instr),
        .E_Instr(E_Instr),
        .M_Instr(M_Instr),
        .E_HILObusy(E_HILObusy),
        .stall(stall)
    );
    wire [31:0] E_WD, M_WD, W_WD, E_pc, M_pc, W_pc, M_C, W_C, W_RD, M_HILO, W_HILO;
    wire [4:0] E_RegDst, M_RegDst, W_RegDst;
    wire [1:0] E_MemtoReg, M_MemtoReg, W_MemtoReg;
    assign E_WD = (E_MemtoReg == `MemtoReg_pc8) ? (E_pc + 8) :
                    0;
    assign M_WD = (M_MemtoReg == `MemtoReg_ALU) ? (M_C) :
                    (M_MemtoReg == `MemtoReg_HILO) ? (M_HILO) :
                    (M_MemtoReg == `MemtoReg_pc8) ? (M_pc + 8) :
                    0;
    assign W_WD = (W_MemtoReg == `MemtoReg_ALU) ? (W_C) :
                    (W_MemtoReg == `MemtoReg_HILO) ? (W_HILO) :
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
        .pc(F_pc)
    );
    assign i_inst_addr = F_pc;

    //D_stage
    wire [31:0] D_pc;
    wire D_REG_Wr = !stall;
    wire D_REG_reset = 1'b0;
    D_REG D_reg (
        .Instr_in(i_inst_rdata),
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
    assign w_grf_we = W_RFWr;
    assign w_grf_addr = W_RegDst;
    assign w_grf_wdata = W_WD;
    assign w_inst_addr = W_pc;

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


    wire [3:0] E_ALUOp, E_HILOOp;
    wire E_ALUASrc, E_ALUBSrc, E_shiftV;
    wire [4:0] E_rs, E_rt;
    CTRL E_CTRL (
        .Instr(E_Instr),
        .rs(E_rs),
        .rt(E_rt),
        .shiftV(E_shiftV),
        .ALUOp(E_ALUOp),
        .HILOOp(E_HILOOp),
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
    assign E_A = (E_ALUASrc == `ALUASrc_rs && !E_shiftV) ? E_FWD_RD1 :
                (E_ALUASrc == `ALUASrc_rs && E_shiftV) ? {27'b0, E_FWD_RD1[4:0]} :
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


    wire [31:0] E_HILO;
    E_HILO E_hilo (
        .clk(clk),
        .reset(reset),
        .RD1(E_FWD_RD1),
        .RD2(E_FWD_RD2),
        .HILOOp(E_HILOOp),
        .HILObusy(E_HILObusy),
        .HILOout(E_HILO)
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
        .HILO_in(E_HILO),
        .Instr_out(M_Instr),
        .pc_out(M_pc),
        .C_out(M_C),
        .EXTout_out(M_EXTout),
        .RD2_out(M_RD2),
        .HILO_out(M_HILO)
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
    wire [31:0] M_FWD_RD2 = (M_rt == 0) ? 0 :
                            (M_rt == W_RegDst) ? W_WD :
                            M_RD2;
    assign m_inst_addr = M_pc;
    assign m_data_addr = M_C;
    assign m_data_wdata = (M_DMOp == `DM_w) ? M_FWD_RD2 :
                            (M_DMOp == `DM_h) ? {M_FWD_RD2[15:0], M_FWD_RD2[15:0]} :
                            (M_DMOp == `DM_b) ? {M_FWD_RD2[7:0], M_FWD_RD2[7:0], M_FWD_RD2[7:0], M_FWD_RD2[7:0]} :
                            M_FWD_RD2;
    assign m_data_byteen = (!M_DMWr) ? 4'b0000 :
                            (M_DMOp == `DM_w) ? 4'b1111 :
                            (M_DMOp == `DM_h && !M_C[1]) ? 4'b0011 :
                            (M_DMOp == `DM_h && M_C[1]) ? 4'b1100 : 
                            (M_DMOp == `DM_b && M_C[1:0] == 2'b00) ? 4'b0001 :
                            (M_DMOp == `DM_b && M_C[1:0] == 2'b01) ? 4'b0010 :
                            (M_DMOp == `DM_b && M_C[1:0] == 2'b10) ? 4'b0100 :
                            (M_DMOp == `DM_b && M_C[1:0] == 2'b11) ? 4'b1000 :
                            4'b0000;
    wire [31:0] M_RD = (M_DMOp == `DM_w) ? m_data_rdata :
                        (M_DMOp == `DM_h) ? {{16{m_data_rdata[15 + 16 * M_C[1]]}}, m_data_rdata[15 + 16 * M_C[1] -: 16]} :
                        (M_DMOp == `DM_hu) ? {{16{1'b0}}, m_data_rdata[15 + 16 * M_C[1] -: 16]} :
                        (M_DMOp == `DM_b) ? {{24{m_data_rdata[7 + 8 * M_C[1:0]]}}, m_data_rdata[7 + 8 * M_C[1:0] -: 8]} :
                        (M_DMOp == `DM_bu) ? {{24{1'b0}}, m_data_rdata[7 + 8 * M_C[1:0] -: 8]} :
                        32'h0000_0000;

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
        .HILO_in(M_HILO),
        .EXTout_in(M_EXTout),
        .Instr_out(W_Instr),
        .pc_out(W_pc),
        .C_out(W_C),
        .RD_out(W_RD),
        .EXTout_out(W_EXTout),
        .HILO_out(W_HILO)
    );


    CTRL W_CTRL (
        .Instr(W_Instr),
        .RegDst(W_RegDst),
        .RFWr(W_RFWr),
        .MemtoReg(W_MemtoReg)
    );
endmodule //mips