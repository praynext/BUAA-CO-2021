`timescale 1ns/1ps
`include "macro.v"

module Bridge (
    input wire [31:0] m_data_rdata,
    input wire [31:0] raw_m_data_addr,
    input wire [31:0] raw_m_data_wdata,
    input wire [3:0] raw_m_data_byteen,
    input wire [31:0] TC0_Dout,
    input wire [31:0] TC1_Dout,
    output wire [31:0] m_data_addr,
    output wire [31:0] m_data_wdata,
    output wire [3:0] m_data_byteen,
    output wire [31:0] raw_m_data_rdata,
    output wire [31:0] TC0_Addr,
    output wire [31:0] TC0_Din,
    output wire TC0_WE,
    output wire [31:0] TC1_Addr,
    output wire [31:0] TC1_Din,
    output wire TC1_WE
);
    assign TC0_Addr = raw_m_data_addr;
    assign TC1_Addr = raw_m_data_addr;
    assign m_data_addr = raw_m_data_addr;
    assign TC0_Din = raw_m_data_wdata;
    assign TC1_Din = raw_m_data_wdata;
    assign m_data_wdata = raw_m_data_wdata;
    wire TC0Hit = (raw_m_data_addr >= 32'h0000_7f00) && (raw_m_data_addr <= 32'h0000_7f0b);
    wire TC1Hit = (raw_m_data_addr >= 32'h0000_7f10) && (raw_m_data_addr <= 32'h0000_7f1b);
    wire WE = (| raw_m_data_byteen);
    assign TC0_WE = WE && TC0Hit;
    assign TC1_WE = WE && TC1Hit;
    assign m_data_byteen = (TC0Hit || TC1Hit) ? 4'b0000 : raw_m_data_byteen;
    assign raw_m_data_rdata = TC0Hit ? TC0_Dout :
                                TC1Hit ? TC1_Dout :
                                m_data_rdata;
endmodule //Bridge