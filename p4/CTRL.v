`timescale 1ns/1ps
`include "macro.v"

module CTRL (
    input wire [5:0] opcode,
    input wire [5:0] funct,
    output wire [1:0] NPCOp,
    output wire [1:0] RegDst,
    output wire RFWr,
    output wire ALUSrc,
    output wire [3:0] ALUOp,
    output wire DMWr,
    output wire [2:0] DMOp,
    output wire [1:0] MemtoReg,
    output wire EXTOp,
    output wire [1:0] CMPOp
);
    wire _store, _rtype, _load;
    wire addu, subu, ori, lw, sw, lh, lhu, lb, lbu, sh, sb, beq, lui, jal, j, jr, sll;
    assign _store = (sw || sh || sb);
    assign _rtype = (opcode==`Opcode_special);
    assign _load = (lw || lh || lhu || lb || lbu);

    assign addu = (_rtype&&(funct==`Funct_addu));
    assign subu = (_rtype&&(funct==`Funct_subu));
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
    assign lui = (opcode==`Opcode_lui);
    assign jal = (opcode==`Opcode_jal);
    assign j = (opcode==`Opcode_j);
    assign jr = (_rtype&&(funct==`Funct_jr));
    assign sll = (_rtype&&(funct==`Funct_sll));

    assign NPCOp = beq ?  `NPC_beq :
                    (jal || j) ? `NPC_j :
                    jr ? `NPC_jr :
                    `NPC_pc4;
    assign RegDst = (_rtype) ? `RegDst_rd :
                    (jal) ? `RegDst_ra :
                    `RegDst_rt;
    assign RFWr = !_store && !beq && !j;
    assign DMWr = (sw || sh || sb);
    assign ALUSrc = !_rtype && !beq && !j && !jal;
    assign ALUOp = (subu) ? `ALU_sub :
                    (ori) ? `ALU_or :
                    (sll) ? `ALU_sll :
                    (lui) ? `ALU_lui :
                    `ALU_add;
    assign DMOp = (lw || sw) ? `DM_w :
                    (lh || sh) ? `DM_h :
                    (lhu) ? `DM_hu :
                    (lb || sb) ? `DM_b :
                    (lbu) ? `DM_bu :
                    `DM_w;
    assign MemtoReg = (_load) ? `MemtoReg_DM :
                        (jal) ? `MemtoReg_pc4 :
                        `MemtoReg_ALU;
    assign EXTOp = _store;
    assign CMPOp = (beq) ? `CMP_beq :
                    2'b11;
 endmodule //CTRL