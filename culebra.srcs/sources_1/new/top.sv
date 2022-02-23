`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/21/2022 02:29:15 PM
// Design Name: culebra
// Module Name: top
// Project Name: culebra
// Target Devices: Basys3 Artix7
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`define MANUAL_INPUT

module top
    #(parameter WIDTH = 16,
      parameter A_REGISTER = 'h0,
      parameter INSTRUCTION_POINTER = 'h5,
      parameter STACK_POINTER = 'h6)
    (
        output wire [15:0] led,
        output wire [6:0]  seg,
        output wire        dp,
        output wire [3:0]  an,
        input wire [15:0]  switch,
        input wire         btnC, btnL, btnR, btnU, btnD,
        input wire         clk
    );

    // Our two main registers A, and B.
    wire [WIDTH-1 : 0] reg_page[0:7];

    // These handle whether it's time to add in _this_ clock cycle.
    wire op_enable;
    // Which register should be used for operations (0=b, 1=a).
    wire [2:0] active_reg;
    // Which operation we want to use now (0=add, 1=subtract).
    wire [3:0] active_op;

    // The immediate register, which is used for holding literal values.
    wire [WIDTH-1 : 0] imm_reg;

    `ifdef MANUAL_INPUT
        // debug scope: manually handle which instructions to run.
        debug_op_driver #(.WIDTH(WIDTH)) op_driver (
            .op_enable(op_enable),
            .active_reg(active_reg),
            .active_op(active_op),
            .imm_reg(imm_reg),
            .btnC(btnC), .btnL(btnL), .btnR(btnR), .btnD(btnD), .btnU(btnU),
            .switch(switch),
            .clk(clk)
        );
        // debug scope: show the currently selected operation and register in display.
        debug_display #(.WIDTH(WIDTH)) display (
            .seg(seg),
            .dp(dp),
            .an(an),
            .led(led),
            .reg_page(reg_page),
            .active_reg(active_reg),
            .active_op(active_op),
            .clk(clk)
        );
    `else // !`ifdef MANUAL_INPUT
        display #(WIDTH, A_REGISTER) display (.led(led), .reg_page(reg_page));
    `endif


    // ALU.
    // Currently handles registers directly, without a bus and a normal pipeline.
    alu #(WIDTH, INSTRUCTION_POINTER, STACK_POINTER) alu (
        .reg_page(reg_page),
        .data_in(imm_reg),
        .enable(op_enable),
        .active_op(active_op),
        .active_reg(active_reg),
        .clk(clk)
    );

endmodule
