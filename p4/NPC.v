`timescale 1ns/1ps
`include "macro.v"

module NPC (
    input wire [31:0] pc,
    input wire [25:0] Imm26,
    input wire [31:0] ra,
    input wire [1:0] NPCOp,
    input wire zerocheck,
    output wire [31:0] npc,
    output wire [31:0] pc4
);
    assign pc4 = pc + 4;
    assign npc = (NPCOp == `NPC_pc4) ? (pc + 4) :
                ((NPCOp == `NPC_beq) && zerocheck) ? (pc + 4 + {{14{Imm26[15]}}, Imm26[15:0], 2'b0}) :
                (NPCOp == `NPC_j) ? {pc[31:28], Imm26[25:0], 2'b0} :
                (NPCOp == `NPC_jr) ? ra :
                (pc + 4);
endmodule //NPC