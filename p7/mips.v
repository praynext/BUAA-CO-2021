`timescale 1ns/1ps
`include "CPU_mips.v"
`include "timer.v"
`include "Bridge.v"

module mips (
    input wire clk,
    input wire reset,
    input wire interrupt,
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
    output wire [31:0] w_inst_addr
);
    wire [31:0] raw_m_data_addr, raw_m_data_wdata, raw_m_data_rdata;
    wire [3:0] raw_m_data_byteen;
    wire TC0_IRQ, TC1_IRQ;
    wire [5:0] HWInt = {3'b000, interrupt, TC1_IRQ, TC0_IRQ};
    wire [31:0] Bridge_m_data_addr;
    wire [3:0] Bridge_m_data_byteen;
    CPU_mips cpu_mips (
        .clk(clk),
        .reset(reset),
        .HWInt(HWInt),
        .i_inst_rdata(i_inst_rdata),
        .m_data_rdata(raw_m_data_rdata),
        .macroscopic_pc(macroscopic_pc),
        .i_inst_addr(i_inst_addr),
        .m_data_addr(raw_m_data_addr),
        .m_data_wdata(raw_m_data_wdata),
        .m_data_byteen(raw_m_data_byteen),
        .m_inst_addr(m_inst_addr),
        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),
        .w_inst_addr(w_inst_addr),
        .exIR(exIR)
    );
    assign m_data_addr = (exIR && interrupt) ? 32'h0000_7f20 : Bridge_m_data_addr;
    assign m_data_byteen = (exIR && interrupt) ? 1 : Bridge_m_data_byteen;


    wire [31:0] TC0_Addr, TC0_Din, TC0_Dout;
    wire [31:0] TC1_Addr, TC1_Din, TC1_Dout;
    Bridge bridge (
        .m_data_rdata(m_data_rdata),
        .raw_m_data_addr(raw_m_data_addr),
        .raw_m_data_wdata(raw_m_data_wdata),
        .raw_m_data_byteen(raw_m_data_byteen),
        .TC0_Dout(TC0_Dout),
        .TC1_Dout(TC1_Dout),
        .m_data_addr(Bridge_m_data_addr),
        .m_data_wdata(m_data_wdata),
        .m_data_byteen(Bridge_m_data_byteen),
        .raw_m_data_rdata(raw_m_data_rdata),
        .TC0_Addr(TC0_Addr),
        .TC0_Din(TC0_Din),
        .TC0_WE(TC0_WE),
        .TC1_Addr(TC1_Addr),
        .TC1_Din(TC1_Din),
        .TC1_WE(TC1_WE)
    );


    TC tc0 (
        .clk(clk),
        .reset(reset),
        .Addr(TC0_Addr[31:2]),
        .WE(TC0_WE),
        .Din(TC0_Din),
        .Dout(TC0_Dout),
        .IRQ(TC0_IRQ)
    );


    TC tc1 (
        .clk(clk),
        .reset(reset),
        .Addr(TC1_Addr[31:2]),
        .WE(TC1_WE),
        .Din(TC1_Din),
        .Dout(TC1_Dout),
        .IRQ(TC1_IRQ)
    );
endmodule //mips