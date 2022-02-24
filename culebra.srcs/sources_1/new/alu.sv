`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/22/2022 06:12:37 PM
// Design Name: culebra
// Module Name: alu
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


module alu
    #(parameter WIDTH = 8,
      parameter INSTRUCTION_POINTER = 'h5,
      parameter STACK_POINTER = 'h6)
    (

        // Page with registers. TODO: bus this
        output reg [WIDTH-1 : 0] reg_page[0:7],
        // CPU flags for conditional jumps.
        output reg [1:0]         flags,
        // The immediate register (input value).
        input wire [WIDTH-1 : 0] data_in,
        // operation to run.
        input wire [4:0]         active_op,
        // destination register.
        input wire [2:0]         active_reg,
        // whether we should enable this alu this clock cycle.
        input wire               enable,
        // the clock
        input wire               clk
    );

    // This is used when we need to load a value from a register before passing it
    // as input.
    reg [WIDTH-1 : 0] op_input;
    always @(posedge clk) begin
        if (enable) begin
            // If the fifth bit of the operation is set, that means this is
            // an indirect operation, so we load the input from the register
            // being pointed to before continuing.
            op_input = active_op[4] ? reg_page[data_in[2:0]] : data_in;
            case (active_op[3:0])
                4'h0: reg_page[active_reg] = reg_page[active_reg] - op_input; // subtract
                4'h1: reg_page[active_reg] = reg_page[active_reg] + op_input; // add
                4'h2: reg_page[active_reg] = reg_page[active_reg] & op_input; // bitwise and
                4'h3: reg_page[active_reg] = reg_page[active_reg] | op_input; // bitwise or
                4'h4: reg_page[active_reg] = reg_page[active_reg] ^ op_input; // bitwise xor
                4'h5: reg_page[active_reg] = op_input;                        // load value
                4'h6: reg_page[active_reg] = ~reg_page[active_reg];           // bitwise not
                default: reg_page[active_reg] = 'b0;                         // DEFAULT: load 0
            endcase
            // After operating, sum 1 to the instruction pointer, but only
            // when the ALU is enabled.
            reg_page[INSTRUCTION_POINTER] = reg_page[INSTRUCTION_POINTER] + 'b1;
        end
    end
endmodule
