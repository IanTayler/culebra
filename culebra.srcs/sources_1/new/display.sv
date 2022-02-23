`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/23/2022 03:30:20 PM
// Design Name: culebra
// Module Name: display
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


module display
    #(parameter WIDTH = 8,
      parameter A_REGISTER = 'h0)
    (
        output wire [WIDTH - 1 : 0] led,
        input wire [WIDTH - 1 : 0]  reg_page [0:7]
    );
    // Show the A register as binary in the LEDs.
    assign led = reg_page[A_REGISTER];

endmodule
