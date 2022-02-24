`timescale 1ns/1ps
`include "macro.v"

module CTRL (
    input wire [31:0] Instr,
    //Decode
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire [4:0] rd,
    output wire [15:0] Imm16,
    output wire [25:0] Imm26,
    //type_signal
    output wire _rtype,
    output wire _itype,
    output wire _load,
    output wire _store,
    output wire _branch,
    output wire _j_addr,
    output wire _j_link,
    output wire _j_reg,
    output wire shiftS,
    //D_stage
    output wire EXTOp,
    output wire [2:0] CMPOp,
    output wire [2:0] NPCOp,
    //E_stage
    output wire [3:0] ALUOp,
    output wire ALUASrc,
    output wire ALUBSrc,
    //M_stage
    output wire [2:0] DMOp,
    output wire DMWr,
    //W_stage
    output wire [4:0] RegDst,
    output wire RFWr,
    output wire [1:0] MemtoReg
);
    wire [5:0] opcode = Instr[31:26];
    wire [5:0] funct = Instr[5:0];
    assign rs = Instr[25:21];
    assign rt = Instr[20:16];
    assign rd = Instr[15:11];
    assign Imm16 = Instr[15:0];
    assign Imm26 = Instr[25:0];

    wire addu, addi, subu, ori, lw, sw, lh, lhu, lb, lbu, sh, sb, beq, bne, bgtz, bltz, bgez, blez, lui, jal, j, jr, sll, sllv;
    assign _rtype = (opcode==`Opcode_special);
    assign _itype = (ori || lui || addi);
    assign _store = (sw || sh || sb);
    assign _load = (lw || lh || lhu || lb || lbu);
    assign _branch = (beq || bne || bgtz || bltz || bgez || blez);
    assign _j_addr = (j);
    assign _j_link = (jal);
    assign _j_reg = (jr);
    assign shiftS = (sll);

    assign addu = (_rtype&&(funct==`Funct_addu));
    assign subu = (_rtype&&(funct==`Funct_subu));
    assign addi = (opcode==`Opcode_addi);
    assign ori = (opcode==`Opcode_ori);
    assign lw = (opcode==`Opcode_lw);
    assign sw = (opcode==`Opcode_sw);
    assign lh = (opcode==`Opcode_lh);
    assign lhu = (opcode==`Opcode_lhu);
    assign lb = (opcode==`Opcode_lb);
    assign lbu = (opcode==`Opcode_lbu);
    assign sh = (opcode==`Opcode_sh);
    assign sb = (opcode==`Opcode_sb);
    assign beq = (opcode==`Opcode_beq);
    assign bne = (opcode==`Opcode_bne);
    assign bgtz = (opcode==`Opcode_bgtz);
    assign bltz = (opcode==`Opcode_bltz);
    assign bgez = (opcode==`Opcode_bgez);
    assign blez = (opcode==`Opcode_blez);
    assign lui = (opcode==`Opcode_lui);
    assign jal = (opcode==`Opcode_jal);
    assign j = (opcode==`Opcode_j);
    assign jr = (_rtype&&(funct==`Funct_jr));
    assign sll = (_rtype&&(funct==`Funct_sll));
    //D_stage
    assign EXTOp = (_store||_load||addi);
    assign CMPOp = (beq) ? `CMP_beq :
                    (bne) ? `CMP_bne :
                    (bgtz) ? `CMP_bgtz :
                    (bltz) ? `CMP_bltz :
                    (bgez) ? `CMP_bgez :
                    (blez) ? `CMP_blez :
                    `CMP_beq;
    assign NPCOp = _branch ?  `NPC_branch :
                    (jal || j) ? `NPC_j :
                    jr ? `NPC_jr :
                    `NPC_pc4;
    //E_stage
    assign ALUOp = (subu) ? `ALU_sub :
                    (ori) ? `ALU_or :
                    (sll) ? `ALU_sll :
                    (lui) ? `ALU_lui :
                    `ALU_add;
    assign ALUASrc = (shiftS) ? `ALUASrc_shamt : `ALUASrc_rs;
    assign ALUBSrc = (_itype || _load || _store) ? `ALUBSrc_EXT : `ALUBSrc_rt;
    //M_stage
    assign DMOp = (lw || sw) ? `DM_w :
                    (lh || sh) ? `DM_h :
                    (lhu) ? `DM_hu :
                    (lb || sb) ? `DM_b :
                    (lbu) ? `DM_bu :
                    `DM_w;
    assign DMWr = _store;
    //W_stage
    assign RegDst = (_rtype) ? rd :
                    (jal) ? 5'd31 :
                    (_load || _itype) ? rt :
                    5'b00000;
    assign RFWr = !(!RegDst);
    assign MemtoReg = (_load) ? `MemtoReg_DM :
                        (jal) ? `MemtoReg_pc8 :
                        `MemtoReg_ALU;
endmodule //CTRL