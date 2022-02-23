`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/23/2022 06:06:18 PM
// Design Name: culebra
// Module Name: slow_clock
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


module slow_clock
    #(parameter WAIT_WIDTH=32,
      parameter WAIT_CYCLES='h1000)
    (
        output reg slow_clk,
        input wire clk
    );

    reg [WAIT_WIDTH-1 : 0] counter;
    always @(posedge clk) begin
        if (counter == 'h0) begin
            slow_clk = slow_clk + 'b1;
            counter = WAIT_CYCLES;
        end else
            counter = counter - 'b1;
    end


endmodule
