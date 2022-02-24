`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/23/2022 05:38:36 PM
// Design Name: culebra
// Module Name: op_driver
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


module op_driver
    #(parameter WIDTH = 8)
    (
        output reg                 op_enable,
        output reg [2:0]           active_reg,
        output reg [3:0]           active_op,
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
                    active_op = instruction[WIDTH*2-1 : WIDTH*2-4];
                    active_reg = instruction[WIDTH*2-5 : WIDTH*2-7];
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
