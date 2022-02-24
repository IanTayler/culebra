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
            // Should multiply 5*4.
            //              LOAD     B         [PAD]            5
            'h00: memory = {5'h05, 3'h1, (WIDTH-8)'('b0), WIDTH'('h5)};
            //              LOAD     Y         [PAD]            4
            'h01: memory = {5'h05, 3'h4, (WIDTH-8)'('b0), WIDTH'('h4)};
            //              SUM%     A         [PAD]           %B
            'h02: memory = {5'h11, 3'h0, (WIDTH-8)'('b0), WIDTH'('h1)};
            //               SUB     Y         [PAD]            1
            'h03: memory = {5'h00, 3'h4, (WIDTH-8)'('b0), WIDTH'('h1)};
            // Loop until Y is 0.
            //               JMP          [PAD]       NZ            1
            'h04: memory = {5'h07, (WIDTH-5)'('b0), 3'b001, (WIDTH-3)'('h1)};
            // Loop forever.
            //               JMP          [PAD]     ALWAYS           4
            'h05: memory = {5'h07, (WIDTH-5)'('b0), 3'b111, (WIDTH-3)'('h4)};
            default: memory = 'h00;
        endcase
    end

endmodule
