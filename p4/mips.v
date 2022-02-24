`timescale 1ns/1ps
`include "macro.v"
`include "ALU.v"
`include "CMP.v"
`include "CTRL.v"
`include "DM.v"
`include "EXT.v"
`include "GRF.v"
`include "IFU.v"
`include "NPC.v"

module mips (
    input wire clk,
    input wire reset
);
    wire [31:0] pc, pc4, Instr, npc, RD1, RD2, EXTout, RD, C;
    wire [4:0] rs, rt, rd;
    wire [15:0] Imm16;
    wire [25:0] Imm26;
    wire [5:0] funct, opcode;
    wire [4:0] shamt;
    wire [3:0] ALUOp;
    wire [2:0] DMOp;
    wire [1:0] CMPOp, NPCOp, RegDst, MemtoReg;
    wire zerocheck, RFWr, ALUSrc, DMWr, EXTOp;

    NPC Npc(
        .pc(pc),
        .Imm26(Imm26),
        .ra(RD1),
        .NPCOp(NPCOp),
        .zerocheck(zerocheck),
        .npc(npc),
        .pc4(pc4)
    );

    IFU Ifu(
        .npc(npc),
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .Instr(Instr),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .Imm16(Imm16),
        .Imm26(Imm26),
        .opcode(opcode),
        .funct(funct),
        .shamt(shamt)
    );

    EXT Ext(
        .Imm16(Imm16),
        .EXTOp(EXTOp),
        .EXTout(EXTout)
    );

    CMP Cmp(
        .RD1(RD1),
        .RD2(RD2),
        .CMPOp(CMPOp),
        .zerocheck(zerocheck)
    );

    GRF Grf(
        .pc(pc),
        .A1(rs),
        .A2(rt),
        .A3(
            (RegDst == `RegDst_rd) ? rd :
            (RegDst == `RegDst_rt) ? rt :
            (RegDst == `RegDst_ra) ? 5'd31 :
            5'd0
        ),
        .WD(
            (MemtoReg == `MemtoReg_ALU) ? C :
            (MemtoReg == `MemtoReg_DM) ? RD :
            (MemtoReg == `MemtoReg_pc4) ? pc4 :
            32'd0
        ),
        .clk(clk),
        .reset(reset),
        .RFWr(RFWr),
        .RD1(RD1),
        .RD2(RD2)
    );

    ALU Alu(
        .ALUOp(ALUOp),
        .A(RD1),
        .B(ALUSrc ? EXTout : RD2),
        .shamt(shamt),
        .C(C)
    );

    DM Dm(
        .pc(pc),
        .Addr(C),
        .WD(RD2),
        .DMOp(DMOp),
        .DMWr(DMWr),
        .clk(clk),
        .reset(reset),
        .RD(RD)
    );

    CTRL Ctrl(
        .opcode(opcode),
        .funct(funct),
        .NPCOp(NPCOp),
        .RegDst(RegDst),
        .RFWr(RFWr),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .DMWr(DMWr),
        .DMOp(DMOp),
        .MemtoReg(MemtoReg),
        .EXTOp(EXTOp),
        .CMPOp(CMPOp)
    );

endmodule //mips