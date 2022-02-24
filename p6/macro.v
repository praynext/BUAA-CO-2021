//opcode & funct & rt
`define Opcode_special 6'b000000
`define Opcode_addi 6'b001000
`define Opcode_addiu 6'b001001
`define Opcode_andi 6'b001100
`define Opcode_beq 6'b000100
`define Opcode_bgez 6'b000001
`define Opcode_bgtz 6'b000111
`define Opcode_blez 6'b000110
`define Opcode_bltz 6'b000001
`define Opcode_bne 6'b000101
`define Opcode_j 6'b000010
`define Opcode_jal 6'b000011
`define Opcode_lb 6'b100000
`define Opcode_lbu 6'b100100
`define Opcode_lh 6'b100001
`define Opcode_lhu 6'b100101
`define Opcode_lui 6'b001111
`define Opcode_lw 6'b100011
`define Opcode_ori 6'b001101
`define Opcode_sb 6'b101000
`define Opcode_sh 6'b101001
`define Opcode_slti 6'b001010
`define Opcode_sltiu 6'b001011
`define Opcode_sw 6'b101011
`define Opcode_xori 6'b001110

`define Funct_add 6'b100000
`define Funct_addu 6'b100001
`define Funct_and 6'b100100
`define Funct_div 6'b011010
`define Funct_divu 6'b011011
`define Funct_jalr 6'b001001
`define Funct_jr 6'b001000
`define Funct_mfhi 6'b010000
`define Funct_mflo 6'b010010
`define Funct_mthi 6'b010001
`define Funct_mtlo 6'b010011
`define Funct_mult 6'b011000
`define Funct_multu 6'b011001
`define Funct_nor 6'b100111
`define Funct_or 6'b100101
`define Funct_sll 6'b000000
`define Funct_sllv 6'b000100
`define Funct_slt 6'b101010
`define Funct_sltu 6'b101011
`define Funct_sra 6'b000011
`define Funct_srav 6'b000111
`define Funct_srlv 6'b000110
`define Funct_sub 6'b100010
`define Funct_subu 6'b100011
`define Funct_srl 6'b000010
`define Funct_xor 6'b100110

`define RT_bgez 5'b00001
`define RT_bltz 5'b00000

//ALU
`define ALU_add 4'b0000
`define ALU_sub 4'b0001
`define ALU_or 4'b0010
`define ALU_lui 4'b0011
`define ALU_sll 4'b0100
`define ALU_and 4'b0101
`define ALU_xor 4'b0110
`define ALU_nor 4'b0111
`define ALU_srl 4'b1000
`define ALU_sra 4'b1001
`define ALU_slt 4'b1010
`define ALU_sltu 4'b1011

//HILO
`define HILO_mult 4'b0001
`define HILO_multu 4'b0010
`define HILO_div 4'b0011
`define HILO_divu 4'b0100
`define HILO_mfhi 4'b0101
`define HILO_mflo 4'b0110
`define HILO_mthi 4'b0111
`define HILO_mtlo 4'b1000

//DM
`define DM_w 3'b000
`define DM_h 3'b001
`define DM_hu 3'b010
`define DM_b 3'b011
`define DM_bu 3'b100

//NPC
`define NPC_pc4 3'b000
`define NPC_branch 3'b001
`define NPC_j 3'b010
`define NPC_jr 3'b011

//ALUASrc
`define ALUASrc_rs 1'b0
`define ALUASrc_shamt 1'b1

//ALUBSrc
`define ALUBSrc_rt 1'b0
`define ALUBSrc_EXT 1'b1

//CMP
`define CMP_beq   3'b000
`define CMP_bne   3'b001
`define CMP_blez  3'b010
`define CMP_bgtz  3'b011
`define CMP_bgez  3'b100
`define CMP_bltz  3'b101

//MemtoReg
`define MemtoReg_ALU 2'b00
`define MemtoReg_DM 2'b01
`define MemtoReg_pc8 2'b10
`define MemtoReg_HILO 2'b11