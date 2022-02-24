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
`include "CP0.v"

module CPU_mips (
    input wire clk,
    input wire reset,
    input wire [5:0] HWInt,
    input wire [31:0] i_inst_rdata,
    input wire [31:0] m_data_rdata,
    output wire [31:0] macroscopic_pc,
    output wire [31:0] i_inst_addr,
    output wire [31:0] m_data_addr,
    output wire [31:0] m_data_wdata,
    output wire [3:0] m_data_byteen,
    output wire [31:0] m_inst_addr,
    output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    output wire [31:0] w_inst_addr,
    output wire exIR
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
    wire [31:0] E_WD, M_WD, W_WD, E_pc, M_pc, W_pc, M_C, W_C, W_RD, M_HILO, W_HILO, W_CP0Out;
    wire [4:0] E_RegDst, M_RegDst, W_RegDst;
    wire [2:0] E_MemtoReg, M_MemtoReg, W_MemtoReg;
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
                    (W_MemtoReg == `MemtoReg_CP0) ? (W_CP0Out) :
                    0;

    //F_stage
    wire [31:0] F_pc, npc, raw_F_pc, EPC;
    wire F_IFUWr = !stall;
    wire [4:0] F_AdEL, F_ExcCode;
    wire Req, F_Delaycheck, D_eret;
    wire [2:0] D_NPCOp;
    IFU ifu (
        .Req(Req),
        .npc(npc),
        .clk(clk),
        .reset(reset),
        .IFUWr(F_IFUWr),
        .pc(raw_F_pc)
    );
    assign F_pc = D_eret ? EPC : raw_F_pc;
    assign F_AdEL = ((| F_pc[1:0]) || (F_pc < 32'h0000_3000) || (F_pc > 32'h0000_6ffc));
    assign i_inst_addr = F_pc;
    assign F_Instr = F_AdEL ? 32'd0 : i_inst_rdata;
    assign F_ExcCode = F_AdEL ? `EXC_AdEL : `EXC_none;

    //D_stage
    wire [31:0] D_pc;
    wire D_REG_Wr = !stall;
    wire D_REG_reset = 1'b0;
    wire [4:0] raw_D_ExcCode, D_ExcCode;
    wire D_Delaycheck;
    D_REG D_reg (
        .Req(Req),
        .Instr_in(F_Instr),
        .pc_in(F_pc),
        .Delaycheck_in(F_Delaycheck),
        .ExcCode_in(F_ExcCode),
        .D_REG_Wr(D_REG_Wr),
        .clk(clk),
        .reset(reset || D_REG_reset),
        .Instr_out(D_Instr),
        .pc_out(D_pc),
        .Delaycheck_out(D_Delaycheck),
        .ExcCode_out(raw_D_ExcCode)
    );


    wire [4:0] D_rs, D_rt;
    wire [15:0] D_Imm16;
    wire [25:0] D_Imm26;
    wire D_EXTOp, D_RI;
    wire [2:0] D_CMPOp;
    CTRL D_CTRL (
        .Instr(D_Instr),
        .rs(D_rs),
        .rt(D_rt),
        .Imm16(D_Imm16),
        .Imm26(D_Imm26),
        .EXTOp(D_EXTOp),
        .CMPOp(D_CMPOp),
        .NPCOp(D_NPCOp),
        .eret(D_eret),
        .RI(D_RI)
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
        .Req(Req),
        .eret(D_eret),
        .EPC(EPC),
        .D_pc(D_pc),
        .F_pc(F_pc),
        .Imm26(D_Imm26),
        .ra(D_FWD_RD1),
        .NPCOp(D_NPCOp),
        .zerocheck(D_zerocheck),
        .npc(npc),
        .Delaycheck(F_Delaycheck)
    );

    assign D_ExcCode = raw_D_ExcCode ? raw_D_ExcCode :
                        D_RI ? `EXC_RI :
                        `EXC_none;


    //E_stage
    wire [31:0] E_EXTout, E_RD1, E_RD2;
    wire [4:0] raw_E_ExcCode, E_ExcCode;
    wire E_REG_Wr = 1'b1;
    wire E_REG_reset = stall;
    E_REG E_reg (
        .Req(Req),
        .stall(stall),
        .RD1_in(D_FWD_RD1),
        .RD2_in(D_FWD_RD2),
        .Instr_in(D_RI ? 32'd0 : D_Instr),
        .EXT_in(D_EXTout),
        .pc_in(D_pc),
        .Delaycheck_in(D_Delaycheck),
        .ExcCode_in(D_ExcCode),
        .clk(clk),
        .reset(reset || E_REG_reset),
        .E_REG_Wr(E_REG_Wr),
        .Instr_out(E_Instr),
        .EXT_out(E_EXTout),
        .pc_out(E_pc),
        .RD1_out(E_RD1),
        .RD2_out(E_RD2),
        .Delaycheck_out(E_Delaycheck),
        .ExcCode_out(raw_E_ExcCode)
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
        .MemtoReg(E_MemtoReg),
        .eret(E_eret),
        .ExcAriOv(E_ALUAriOv),
        .ExcDMOv(E_ALUDMOv)
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
        .ALUAriOv(E_ALUAriOv),
        .ALUDMOv(E_ALUDMOv),
        .ALUOp(E_ALUOp),
        .A(E_A),
        .B(E_B),
        .C(E_C),
        .ExcAriOv(E_ExcAriOv),
        .ExcDMOv(E_ExcDMOv)
    );


    wire [31:0] E_HILO;
    E_HILO E_hilo (
        .Req(Req),
        .clk(clk),
        .reset(reset),
        .RD1(E_FWD_RD1),
        .RD2(E_FWD_RD2),
        .HILOOp(E_HILOOp),
        .HILObusy(E_HILObusy),
        .HILOout(E_HILO)
    );
    assign E_ExcCode = (raw_E_ExcCode) ? raw_E_ExcCode :
                        (E_ExcAriOv) ? `EXC_Ov :
                        `EXC_none;

    //M_stage
    wire [31:0] M_EXTout, M_RD2;
    wire [4:0] raw_M_ExcCode, M_ExcCode;
    wire M_REG_Wr = 1'b1;
    wire M_REG_reset = 1'b0;
    M_REG M_reg (
        .Req(Req),
        .clk(clk),
        .reset(reset || M_REG_reset),
        .M_REG_Wr(M_REG_Wr),
        .Instr_in(E_Instr),
        .pc_in(E_pc),
        .C_in(E_C),
        .EXTout_in(E_EXTout),
        .RD2_in(E_FWD_RD2),
        .HILO_in(E_HILO),
        .Delaycheck_in(E_Delaycheck),
        .ExcCode_in(E_ExcCode),
        .ExcDMOv_in(E_ExcDMOv),
        .Instr_out(M_Instr),
        .pc_out(M_pc),
        .C_out(M_C),
        .EXTout_out(M_EXTout),
        .RD2_out(M_RD2),
        .HILO_out(M_HILO),
        .Delaycheck_out(M_Delaycheck),
        .ExcCode_out(raw_M_ExcCode),
        .ExcDMOv_out(M_ExcDMOv)
    );


    wire M_store, M_load, M_DMOv;
    wire [4:0] M_rt, M_rd;
    wire [2:0] M_DMOp;
    wire M_DMWr;
    CTRL M_CTRL (
        .eret(M_eret),
        .Instr(M_Instr),
        .rd(M_rd),
        .rt(M_rt),
        ._store(M_store),
        ._load(M_load),
        .DMOp(M_DMOp),
        .DMWr(M_DMWr),
        .RegDst(M_RegDst),
        .MemtoReg(M_MemtoReg),
        .CP0Wr(M_CP0Wr)
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
    assign m_data_byteen = (!(M_DMWr && !Req)) ? 4'b0000 :
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
    wire AlignError = ((M_DMOp == `DM_w) && (|M_C[1:0])) || ((M_DMOp == `DM_h || M_DMOp == `DM_hu) && (M_C[0]));
    wire OvError = !(((M_C >= 32'h0000_0000) && (M_C <= 32'h0000_2fff)) || 
                    ((M_C >= 32'h0000_7f00) && (M_C <= 32'h0000_7f0b)) ||
                    ((M_C >= 32'h0000_7f10) && (M_C <= 32'h0000_7f1b)));
	wire loadTimerError = ((M_DMOp != `DM_w) && (M_C >= 32'h0000_7f00));
    wire storeTimerError = ((M_C >= 32'h0000_7f08) && (M_C <= 32'h0000_7f0b)) ||
                        ((M_C >= 32'h0000_7f18) && (M_C <= 32'h0000_7f1b)) ||
                        ((M_DMOp != `DM_w) && (M_C >= 32'h0000_7f00));
    wire M_AdES = (M_store) && (AlignError || OvError || storeTimerError || M_ExcDMOv);
    wire M_AdEL = (M_load) && (AlignError || OvError || loadTimerError || M_ExcDMOv);

    assign M_ExcCode = (raw_M_ExcCode) ? raw_M_ExcCode :
                        (M_AdES) ? `EXC_AdES :
                        (M_AdEL) ? `EXC_AdEL :
                        `EXC_none;

    //CP0
    wire [31:0] M_CP0Out;
    assign macroscopic_pc = M_pc;
    CP0 cp0 (
        .A1(M_rd),
        .A2(M_rd),
        .Din(M_FWD_RD2),
        .PC(M_pc),
        .Delaycheck(M_Delaycheck),
        .ExcCodeIn(M_ExcCode),
        .HWInt(HWInt),
        .WE(M_CP0Wr),
        .EXLClr(M_eret),
        .clk(clk),
        .reset(reset),
        .Req(Req),
        .EPCOut(EPC),
        .DOut(M_CP0Out),
        .exIR(exIR)
    );

    //W_stage
    wire W_REG_Wr = 1'b1;
    wire W_REG_reset = 1'b0;
    wire [31:0] W_EXTout;
    W_REG W_reg (
        .Req(Req),
        .clk(clk),
        .reset(reset || W_REG_reset),
        .W_REG_Wr(W_REG_Wr),
        .Instr_in(M_Instr),
        .pc_in(M_pc),
        .C_in(M_C),
        .RD_in(M_RD),
        .HILO_in(M_HILO),
        .CP0_in(M_CP0Out),
        .EXTout_in(M_EXTout),
        .Instr_out(W_Instr),
        .pc_out(W_pc),
        .C_out(W_C),
        .RD_out(W_RD),
        .EXTout_out(W_EXTout),
        .HILO_out(W_HILO),
        .CP0_out(W_CP0Out)
    );


    CTRL W_CTRL (
        .Instr(W_Instr),
        .RegDst(W_RegDst),
        .RFWr(W_RFWr),
        .MemtoReg(W_MemtoReg)
    );
endmodule //CPU_mips