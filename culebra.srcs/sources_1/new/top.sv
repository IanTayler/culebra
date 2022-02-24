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

// // Uncomment for debugging.
// // MANUAL_INPUT lets you control each instrucion manually.
// // Use together with DEBUG_DISPLAY for maximum effect.
// `define MANUAL_INPUT
// // DEBUG_DISPLAY shows which instruction and register are selected.
`define DEBUG_DISPLAY
// // SLOW_CLOCK runs instructions much slower so that you can debug.
// // This only makes sense when MANUAL_INPUT is NOT set.
`define SLOW_CLOCK

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
    // CPU flags used for conditional jumps (jumps not implemented yet).
    wire [1:0]         flags;


    // These handle whether it's time to add in _this_ clock cycle.
    wire op_enable;
    // Which register should be used for operations (0=b, 1=a).
    wire [2:0] active_reg;
    // Which operation we want to use now (0=add, 1=subtract).
    wire [4:0] active_op;

    // The immediate register, which is used for holding literal values.
    wire [WIDTH-1 : 0] imm_reg;

    // Memory. Last read word. This is currently ROM-only and is only used for
    // reading the executable.
    wire [(WIDTH*2)-1 : 0] memory;
    // Address being read from memory. This will be the instruction pointer for us.
    wire [WIDTH-1 : 0]     address;
    // CPU clock. Can be set to a slower speed for debug purposes.
    wire                   cpu_clk;

    // When we want to debug, get a very slow clock for the CPU.
    `ifdef SLOW_CLOCK
        slow_clock #(.WAIT_CYCLES('h3000000)) debug_clock (cpu_clk, clk);
    `else // !`ifdef SLOW_CLOCK
        // Hopefully this indirection won't appear in the final synthesized circuit.
        assign cpu_clk = clk;
    `endif


    program_rom #(.WIDTH(WIDTH)) program_rom (
        .memory(memory),
        .address(address),
        .clk(cpu_clk)
    );


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
    `else // !`ifdef MANUAL_INPUT
        op_driver #(.WIDTH(WIDTH)) op_driver (
            .op_enable(op_enable),
            .active_reg(active_reg),
            .active_op(active_op),
            .imm_reg(imm_reg),
            .address(address),
            .memory(memory),
            .instruction_pointer(reg_page[INSTRUCTION_POINTER]),
            .clk(cpu_clk)
        );


    `endif

    `ifdef DEBUG_DISPLAY
        // debug scope: show the currently selected operation and register in display.
        debug_display #(.WIDTH(WIDTH)) display (
            .seg(seg),
            .dp(dp),
            .an(an),
            .led(led),
            .reg_page(reg_page),
            .active_reg(active_reg),
            .active_op(active_op),
            .flags(flags),
            .clk(clk)
        );
    `else // !`ifdef DEBUG_DISPLAY
        display #(WIDTH, A_REGISTER) display (.led(led), .reg_page(reg_page));
    `endif

    // ALU.
    // Currently handles registers directly, without a bus and a normal pipeline.
    alu #(WIDTH, INSTRUCTION_POINTER, STACK_POINTER) alu (
        .reg_page(reg_page),
        .flags(flags),
        .data_in(imm_reg),
        .enable(op_enable),
        .active_op(active_op),
        .active_reg(active_reg),
        .clk(cpu_clk)
    );

endmodule
