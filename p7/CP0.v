`timescale 1ns/1ps
`define IM SR[15:10]
`define IE SR[0]
`define EXL SR[1]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]
`define BD Cause[31]

module CP0 (
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [31:0] Din,
    input wire [31:0] PC,
    input wire [4:0] ExcCodeIn,
    input wire [5:0] HWInt,
    input wire Delaycheck,
    input wire WE,
    input wire EXLClr,
    input wire clk,
    input wire reset,
    output wire Req,
    output wire [31:0] EPCOut,
    output wire [31:0] DOut,
    output wire exIR
);
    reg [31:0] SR;
    reg [31:0] Cause;
    reg [31:0] EPC;
    reg [31:0] PRId;
    initial begin
        SR <= 0;
        Cause <= 0;
        EPC <= 0;
        PRId <= 32'h2003_1015;
    end
    wire IntReq = !`EXL && `IE && (| (HWInt & `IM));
    wire ExcReq = !`EXL && (| ExcCodeIn);
    assign Req = IntReq | ExcReq;
    wire [31:0] tempEPC = (Req) ? (Delaycheck ? {PC - 32'd4} : PC) : EPC;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            SR <= 0;
            Cause <= 0;
            EPC <= 0;
            PRId <= 32'h2003_1015;
        end
        else begin
            if (EXLClr) begin
                `EXL <= 1'b0;
            end
            if (Req) begin
                `ExcCode <= IntReq ? 5'd0 : ExcCodeIn;
                `EXL <= 1'b1;
                EPC <= tempEPC;
                `BD <= Delaycheck;
            end
            else if (WE) begin
                if (A2 == 12) begin
                    SR <= Din;
                end
                else if (A2 == 14) begin
                    EPC <= Din;
                end
            end
            `IP <= HWInt;
        end
    end
    assign EPCOut = tempEPC;
    assign DOut = (A1 == 12) ? SR :
                    (A1 == 13) ? Cause :
                    (A1 == 14) ? EPCOut :
                    (A1 == 15) ? PRId :
                    0;
    assign exIR = !`EXL && `IE && (HWInt[2] & SR[12]);
endmodule //CP0