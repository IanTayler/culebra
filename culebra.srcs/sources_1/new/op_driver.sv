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


module op_driver
    #(parameter WIDTH = 16)
    (
        output reg                 op_enable,
        output reg [2:0]           op_modifier,
        output reg [4:0]           active_op,
        output reg [WIDTH-1 : 0]   imm_reg,
        output reg [WIDTH-1 : 0]   address,
        input wire [WIDTH*2-1 : 0] memory,
        input wire [WIDTH-1 : 0]   instruction_pointer,
        input wire                 clk
    );

    // The pipeline is:
    // 1. Read instruction_pointer, this sets the address.
    // 2. Next clock cycle we're loading the instruction into memory.
    // 3. Set op_enable.
    // 4. Wait for the CPU to run. Then repeat.
    reg set, loaded, ready;
    reg [WIDTH*2-1 : 0] instruction;

    initial begin
        // This should actually be implied, but let's make it explicit.
        address = 'h00;
        set = 'b0;
        loaded = 'b0;
        ready = 'b0;
        op_enable = 'b0;
    end
    always @(posedge clk) begin
        // NOTE: We may want to break some instructions into multiple cycles
        // in the future, but not yet.
        if (ready) begin // Ready! Set new address.
            if (set) begin // Address set! Wait until it loads.
                if (loaded) begin // Loaded! Set instruction.
                    // Load the instruction.
                    instruction = memory;
                    // Parse instruction.
                    imm_reg = instruction[WIDTH-1 : 0];
                    active_op = instruction[WIDTH*2-1 : WIDTH*2-5];
                    op_modifier = instruction[WIDTH*2-6 : WIDTH*2-8];
                    // Set enable.
                    op_enable = 'b1;
                    // Reset pipeline state.
                    loaded = 'b0;
                    set = 'b0;
                    ready = 'b0;
                end else begin // Not loaded
                    loaded = 'b1;
                end
            end else begin // Not set
                // Load the address that will be used next cycle.
                address = instruction_pointer;
                set = 'b1;
            end
        end else begin // Not ready
            ready = 'b1;
            op_enable = 'b0;
        end
    end

endmodule
