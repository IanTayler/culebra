`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit
// Engineer: Ian Tayler
//
// Create Date: 02/22/2022 07:16:31 PM
// Design Name: culebra
// Module Name: debug_op_driver
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


module debug_op_driver
    #(parameter WIDTH = 8)
    (
        output reg              op_enable,
        output reg [2:0]        active_reg,
        output reg [3:0]        active_op,
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
                active_reg = active_reg - 'b1;
            else if (btnR)
                active_reg = active_reg + 'b1;
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
