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
            //               SUM    A         [PAD]            0
            'h00: memory = {4'h1, 3'h0, (WIDTH-7)'('b0), WIDTH'('h0)};
            //               XOR    A         [PAD]            7
            'h01: memory = {4'h4, 3'h0, (WIDTH-7)'('b0), WIDTH'('b111)};
            //               OR     A         [PAD]           238
            'h02: memory = {4'h3, 3'h0, (WIDTH-7)'('b0), WIDTH'('hee)};
            //               ADD    A         [PAD]            9
            'h03: memory = {4'h1, 3'h0, (WIDTH-7)'('b0), WIDTH'('h3)};
            //               SUB    P         [PAD]            4
            'h04: memory = {4'h0, 3'h5, (WIDTH-7)'('b0), WIDTH'('h4)}; // loop forever
            default: memory = 'h00;
        endcase
    end

endmodule
