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


module debug_op_driver
    #(parameter WIDTH = 16)
    (
        output reg              op_enable,
        output reg [2:0]        op_modifier,
        output reg [4:0]        active_op,
        output wire [WIDTH-1:0] imm_reg,
        input wire              btnC, btnL, btnR, btnD, btnU,
        input wire [15:0]       switch,
        input wire              clk
    );

    reg last_op_btn;
    // trigger operation with central button.
    always @(posedge clk) begin
        if (!btnC)
            op_enable = 'b0;
        else if (last_op_btn)
            op_enable = 'b0;
        else // Switch enabled just now:
            op_enable = 'b1;
        last_op_btn = btnC;
    end

    // switch register when btnL and btnR are pressed.
    // switch op when btnD and btnU are pressed.
    // do everything with some debouncing.
    reg [25:0] debounce_counter;
    always @(posedge clk) begin
        if (debounce_counter == 'h0) begin
            if (btnL | btnR | btnC | btnD | btnU)
                debounce_counter = {25{1'b1}};
            if (btnL)
                op_modifier = op_modifier - 'b1;
            else if (btnR)
                op_modifier = op_modifier + 'b1;
            if (btnD)
                active_op = active_op - 'b1;
            else if (btnU)
                active_op = active_op + 'b1;
        end else // (debounce_counter != 'h0)
            debounce_counter = debounce_counter - 'b1;

    end

    // debug scope: set the immediate register from the switches.
    assign imm_reg = switch[WIDTH-1 : 0];

endmodule
