`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/23/2022 11:29:11 AM
// Design Name: culebra
// Module Name: program_rom
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


module program_rom
    #(parameter WIDTH = 8)
	(
		output reg [(WIDTH*2)-1 : 0] memory,
		input wire [WIDTH-1 : 0] address,
		input wire clk
	);

	(* rom_style = "block" *)

    reg [WIDTH-1 : 0] address_reg;

    always @(posedge clk) begin
        address_reg <= address;
    end
	always @* begin
        case (address_reg)
            // Should get 4 LEDs with different brightness.
            //              LOAD    A         [PAD]            0
            'h00: memory = {5'h05, 3'h0, (WIDTH-8)'('b0), WIDTH'('h0)};
            //               XOR    A         [PAD]            15
            'h01: memory = {5'h04, 3'h0, (WIDTH-8)'('b0), WIDTH'('hf)};
            //               AND    A         [PAD]            10
            'h02: memory = {5'h02, 3'h0, (WIDTH-8)'('b0), WIDTH'('ha)};
            //               AND    A         [PAD]            8
            'h03: memory = {5'h02, 3'h0, (WIDTH-8)'('b0), WIDTH'('h8)};
            //              LOAD    P         [PAD]            0
            'h04: memory = {5'h05, 3'h5, (WIDTH-8)'('b0), WIDTH'('h0)}; // loop forever
            default: memory = 'h00;
        endcase
    end

endmodule
