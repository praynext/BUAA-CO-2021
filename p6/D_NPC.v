`timescale 1ns/1ps
`include "macro.v"

module D_NPC (
    input wire [31:0] D_pc,
    input wire [31:0] F_pc,
    input wire [25:0] Imm26,
    input wire [31:0] ra,
    input wire [2:0] NPCOp,
    input wire zerocheck,
    output wire [31:0] npc
);
    assign npc = (NPCOp == `NPC_pc4) ? (F_pc + 4) :
                ((NPCOp == `NPC_branch) && zerocheck) ? (D_pc + 4 + {{14{Imm26[15]}}, Imm26[15:0], 2'b0}) :
                (NPCOp == `NPC_j) ? {D_pc[31:28], Imm26[25:0], 2'b0} :
                (NPCOp == `NPC_jr) ? ra :
                (F_pc + 4);
endmodule //D_NPC