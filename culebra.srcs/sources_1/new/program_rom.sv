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
		output reg [(WIDTH*2)- 1 : 0] memory,
		input wire [WIDTH-1 : 0] address,
		input wire clk
	);

	(* rom_style = "block" *)

	reg [WIDTH-1 : 0] address_reg;

	always @(posedge clk)
		begin
            address_reg <= address;
		end

    always @*
        case (address)
            'h00: memory = 'h10;
            'h01: memory = 'h11;
            'h02: memory = 'h12;
            'h03: memory = 'h13;
            'h04: memory = 'h14;
            'h05: memory = 'h15;
            'h06: memory = 'h16;
            'h07: memory = 'h17;
            'h08: memory = 'h18;
            'h09: memory = 'h19;
            'h0a: memory = 'h1a;
            'h0b: memory = 'h1b;
            'h0c: memory = 'h1c;
            'h0d: memory = 'h1d;
            'h0e: memory = 'h1e;
            'h0f: memory = 'h1f;
            'h10: memory = 'h20;
            default: memory = 'h00;
        endcase
endmodule
