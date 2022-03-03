`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Copyright Ian Tayler 2022.
//
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2.
//
// You may redistribute and modify this source and make products using it under
// the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).
//
// This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
// INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
// PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
//
// Source location: https://github.com/IanTayler/culebra
//
// As per CERN-OHL-S v2 section 4, should You produce hardware based on this
// source, You must where practicable maintain the Source Location visible
// on the external case of the Gizmo or other products you make using this
// source.
////////////////////////////////////////////////////////////////////////////////


module slow_clock
    #(parameter WAIT_WIDTH=32,
      parameter WAIT_CYCLES='h3000000)
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
