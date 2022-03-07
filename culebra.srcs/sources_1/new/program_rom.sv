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


module program_rom
    #(parameter WIDTH = 16)
	(
		output reg [(WIDTH*2)-1 : 0] memory,
		input wire [31:0] address,
		input wire clk
	);

	(* rom_style = "block" *)

    reg [31:0] address_reg;

    always @(posedge clk) begin
        address_reg <= address;
    end
	always @* begin
        case (address_reg)
            // Should multiply 5*4.
            //    INSTRUCTION    | MODIFIER |   PAD      | ARGUMENT;
            //              LOAD     B         [PAD]            5
            'h00: memory = {5'h05, 3'h1, (WIDTH-8)'('b0), WIDTH'('h5)};
            //              LOAD     Y         [PAD]            4
            'h01: memory = {5'h05, 3'h4, (WIDTH-8)'('b0), WIDTH'('h4)};
            //              SUM%     A         [PAD]           %B
            'h02: memory = {5'h11, 3'h0, (WIDTH-8)'('b0), WIDTH'('h1)};
            //               SUB     Y         [PAD]            1
            'h03: memory = {5'h00, 3'h4, (WIDTH-8)'('b0), WIDTH'('h1)};
            // Loop until Y is 0.
            //               JMP     NZ        [PAD]            1
            'h04: memory = {5'h07, 3'h4, (WIDTH-8)'('b0), WIDTH'('h1)};
            // Loop forever.
            //               JMP   UNCOND      [PAD]            4
            'h05: memory = {5'h07, 3'h7, (WIDTH-8)'('b0), WIDTH'('h4)};
            default: memory = 'h00;
        endcase
    end

endmodule
