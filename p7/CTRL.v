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
    output wire shiftV,
    output wire md,
    output wire mf,
    output wire mt,
    //D_stage
    output wire EXTOp,
    output wire [2:0] CMPOp,
    output wire [2:0] NPCOp,
    //E_stage
    output wire [3:0] HILOOp,
    output wire ExcAriOv,
    output wire ExcDMOv,
    output wire [3:0] ALUOp,
    output wire ALUASrc,
    output wire ALUBSrc,
    //M_stage
    output wire [2:0] DMOp,
    output wire DMWr,
    //W_stage
    output wire [4:0] RegDst,
    output wire RFWr,
    output wire [2:0] MemtoReg,
    //CP0
    output wire CP0Wr,
    output wire mfc0,
    output wire mtc0,
    output wire eret,
    output wire RI
);
    wire [5:0] opcode = Instr[31:26];
    wire [5:0] funct = Instr[5:0];
    assign rs = Instr[25:21];
    assign rt = Instr[20:16];
    assign rd = Instr[15:11];
    assign Imm16 = Instr[15:0];
    assign Imm26 = Instr[25:0];

    wire addi = (opcode==`Opcode_addi);
    wire addiu = (opcode==`Opcode_addiu);
    wire andi = (opcode==`Opcode_andi);
    wire beq = (opcode==`Opcode_beq);
    wire bgez = ((opcode==`Opcode_bgez)&&(rt==`RT_bgez));
    wire bgtz = (opcode==`Opcode_bgtz);
    wire blez = (opcode==`Opcode_blez);
    wire bltz = ((opcode==`Opcode_bltz)&&(rt ==`RT_bltz));
    wire bne = (opcode==`Opcode_bne);
    wire j = (opcode==`Opcode_j);
    wire jal = (opcode==`Opcode_jal);
    wire lb = (opcode==`Opcode_lb);
    wire lbu = (opcode==`Opcode_lbu);
    wire lh = (opcode==`Opcode_lh);
    wire lhu = (opcode==`Opcode_lhu);
    wire lui = (opcode==`Opcode_lui);
    wire lw = (opcode==`Opcode_lw);
    wire ori = (opcode==`Opcode_ori);
    wire sb = (opcode==`Opcode_sb);
    wire sh = (opcode==`Opcode_sh);
    wire slti = (opcode==`Opcode_slti);
    wire sltiu = (opcode==`Opcode_sltiu);
    wire sw = (opcode==`Opcode_sw);
    wire xori = (opcode==`Opcode_xori);

    wire add = ((opcode==`Opcode_special)&&(funct==`Funct_add));
    wire addu = ((opcode==`Opcode_special)&&(funct==`Funct_addu));
    wire And = ((opcode==`Opcode_special)&&(funct==`Funct_and));
    wire div = ((opcode==`Opcode_special)&&(funct==`Funct_div));
    wire divu = ((opcode==`Opcode_special)&&(funct==`Funct_divu));
    wire jalr = ((opcode==`Opcode_special)&&(funct==`Funct_jalr));
    wire jr = ((opcode==`Opcode_special)&&(funct==`Funct_jr));
    wire mfhi = ((opcode==`Opcode_special)&&(funct==`Funct_mfhi));
    wire mflo = ((opcode==`Opcode_special)&&(funct==`Funct_mflo));
    wire mthi = ((opcode==`Opcode_special)&&(funct==`Funct_mthi));
    wire mtlo = ((opcode==`Opcode_special)&&(funct==`Funct_mtlo));
    wire mult = ((opcode==`Opcode_special)&&(funct==`Funct_mult));
    wire multu = ((opcode==`Opcode_special)&&(funct==`Funct_multu));
    wire Nor = ((opcode==`Opcode_special)&&(funct==`Funct_nor));
    wire Or = ((opcode==`Opcode_special)&&(funct==`Funct_or));
    wire sll = ((opcode==`Opcode_special)&&(funct==`Funct_sll));
    wire sllv = ((opcode==`Opcode_special)&&(funct==`Funct_sllv));
    wire slt = ((opcode==`Opcode_special)&&(funct==`Funct_slt));
    wire sltu = ((opcode==`Opcode_special)&&(funct==`Funct_sltu));
    wire sra = ((opcode==`Opcode_special)&&(funct==`Funct_sra));
    wire srav = ((opcode==`Opcode_special)&&(funct==`Funct_srav));
    wire srl = ((opcode==`Opcode_special)&&(funct==`Funct_srl));
    wire srlv = ((opcode==`Opcode_special)&&(funct==`Funct_srlv));
    wire sub = ((opcode==`Opcode_special)&&(funct==`Funct_sub));
    wire subu = ((opcode==`Opcode_special)&&(funct==`Funct_subu));
    wire Xor = ((opcode==`Opcode_special)&&(funct==`Funct_xor));

    assign mfc0 = ((opcode==`Opcode_mfc0)&&(rs==`RS_mfc0));
    assign mtc0 = ((opcode==`Opcode_mtc0)&&(rs==`RS_mtc0));
    assign eret = (Instr==`Instr_eret);

    assign _rtype = (add | addu | And | Nor | Or | sll | sllv | slt | sltu | sra | srav | srl | srlv | sub | subu |Xor);
    assign _itype = (addi | addiu | andi | lui | ori | slti | sltiu | xori);
    assign _store = (sw | sh | sb);
    assign _load = (lw | lh | lhu | lb | lbu);
    assign _branch = (beq | bne | bgtz | bltz | bgez | blez);
    assign _j_addr = (j | jal);
    assign _j_link = (jal | jalr);
    assign _j_reg = (jr | jalr);
    assign shiftS = (sll | sra | srl);
    assign shiftV = (sllv | srav | srlv);
    assign md = (mult | multu | div | divu);
    assign mf = (mfhi | mflo);
    assign mt = (mthi | mtlo);

    //D_stage
    assign EXTOp = (_store | _load | addi | addiu | slti | sltiu);
    assign CMPOp = (beq) ? `CMP_beq :
                    (bne) ? `CMP_bne :
                    (bgtz) ? `CMP_bgtz :
                    (bltz) ? `CMP_bltz :
                    (bgez) ? `CMP_bgez :
                    (blez) ? `CMP_blez :
                    `CMP_beq;
    assign NPCOp = _branch ?  `NPC_branch :
                    _j_addr ? `NPC_j :
                    _j_reg ? `NPC_jr :
                    `NPC_pc4;
    //E_stage
    assign ALUOp = (sub | subu) ? `ALU_sub :
                    (lui) ? `ALU_lui :
                    (And | andi) ? `ALU_and :
                    (Or | ori) ? `ALU_or :
                    (Xor | xori) ? `ALU_xor :
                    (Nor) ? `ALU_nor :
                    (sll | sllv) ? `ALU_sll :
                    (srl | srlv) ? `ALU_srl :
                    (sra | srav) ? `ALU_sra :
                    (slt | slti) ? `ALU_slt :
                    (sltu | sltiu) ? `ALU_sltu :
                    `ALU_add;
    assign ALUASrc = (shiftS) ? `ALUASrc_shamt : `ALUASrc_rs;
    assign ALUBSrc = (_itype | _load | _store) ? `ALUBSrc_EXT : `ALUBSrc_rt;
    assign ExcAriOv = add | addi | sub;
    assign ExcDMOv = sw | sh | sb | lw | lh | lhu | lb | lbu;
    assign HILOOp = (mult) ? `HILO_mult :
                    (multu) ? `HILO_multu :
                    (div) ? `HILO_div :
                    (divu) ? `HILO_divu :
                    (mfhi) ? `HILO_mfhi :
                    (mflo) ? `HILO_mflo :
                    (mthi) ? `HILO_mthi :
                    (mtlo) ? `HILO_mtlo :
                    4'b0000;
    //M_stage
    assign DMOp = (lw | sw) ? `DM_w :
                    (lh | sh) ? `DM_h :
                    (lhu) ? `DM_hu :
                    (lb | sb) ? `DM_b :
                    (lbu) ? `DM_bu :
                    `DM_w;
    assign DMWr = _store;
    //W_stage
    assign RegDst = (_rtype | jalr | mf) ? rd :
                    (jal) ? 5'd31 :
                    (_load | _itype | mfc0) ? rt :
                    5'b00000;
    assign RFWr = !(!RegDst);
    assign MemtoReg = _load ? `MemtoReg_DM :
                        _j_link ? `MemtoReg_pc8 :
                        mf ? `MemtoReg_HILO :
                        mfc0 ? `MemtoReg_CP0 :
                        `MemtoReg_ALU;
    assign RI = !(add | addi | addiu | addu | And | andi | beq | bgez | bgtz |
                blez | bltz | bne | div | divu | eret | j | jal | jalr | jr |
                lb | lbu | lh | lhu | lui | lw | mfc0 | mfhi | mflo | mtc0 |
                mthi | mtlo | mult | multu | Nor | Or | ori | sb | sh | sll |
                sllv | slt | slti | sltiu | sltu | sra | srav | srl | srlv |
                sub | subu | sw | Xor | xori);
    assign CP0Wr = mtc0;
endmodule //CTRL