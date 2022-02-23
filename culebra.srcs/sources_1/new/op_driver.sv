`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/23/2022 05:38:36 PM
// Design Name: culebra
// Module Name: op_driver
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


module op_driver
    #(parameter WIDTH = 8,
      parameter INSTRUCTION_POINTER = 'h5)
    (
        output reg                 op_enable,
        output reg [2:0]           active_reg,
        output reg [3:0]           active_op,
        output reg [WIDTH-1 : 0]   imm_reg,
        output reg [WIDTH-1 : 0]   address,
        input wire [WIDTH*2-1 : 0] memory,
        input wire [WIDTH-1 : 0]   reg_page [0:7],
        input wire                 clk
    );

    initial
        address = 'h00;
    always @(posedge clk) begin
        address = reg_page[INSTRUCTION_POINTER];
        // Enable every cycle for now.
        // NOTE: We may want to break some instructions into multiple cycles
        // in the future, but not yet. Keep it simple for now.
        op_enable = 'b1;
        imm_reg = memory[WIDTH-1 : 0];
        active_op = memory[WIDTH*2-1 : WIDTH*2-4];
        active_reg = memory[WIDTH*2-5 : WIDTH*2-7];
    end
endmodule
