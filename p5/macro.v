//opcode & funct
`define Opcode_special 6'b000000
`define Opcode_addi 6'b001000
`define Opcode_ori 6'b001101
`define Opcode_lw 6'b100011
`define Opcode_sw 6'b101011
`define Opcode_lh 6'b100001
`define Opcode_lhu 6'b100101
`define Opcode_lb 6'b100000
`define Opcode_lbu 6'b100100
`define Opcode_sh 6'b101001
`define Opcode_sb 6'b101000
`define Opcode_j 6'b000010
`define Opcode_beq 6'b000100
`define Opcode_bne 6'b000101
`define Opcode_bgez 6'b000001
`define Opcode_bgtz 6'b000111
`define Opcode_blez 6'b000110
`define Opcode_bltz 6'b000001
`define Opcode_jal 6'b000011
`define Opcode_lui 6'b001111

`define Funct_addu 6'b100001
`define Funct_subu 6'b100011
`define Funct_jr 6'b001000
`define Funct_sll 6'b000000

//ALU
`define ALU_add 4'b0000
`define ALU_sub 4'b0001
`define ALU_or 4'b0010
`define ALU_lui 4'b0011
`define ALU_sll 4'b0100

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