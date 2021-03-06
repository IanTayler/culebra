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


module debug_display
    #(parameter WIDTH = 16,
      parameter INSTRUCTION_POINTER = 'h5)
    (
        output reg [6:0]         seg,
        output wire              dp,
        output reg [3:0]         an,
        output wire [15:0]       led,
        input wire [WIDTH-1 : 0] reg_page[0:7],
        input wire [2:0]         op_modifier,
        input wire [4:0]         active_op,
        input wire [1:0]         flags,
        input wire               clk
    );

    wire [6:0] segments [0:3];
    reg [1:0]  counter;
    // Does this op take a flag condition as modifier?
    // Currently only jump satisfies this.
    wire       op_modifier_condition = active_op == 'h7;

    // Show active register value in leds. Ignore highest two bits to
    // show the flags instead.
    assign led[WIDTH-3 : 0] = op_modifier_condition? reg_page[INSTRUCTION_POINTER]
                              : reg_page[op_modifier];
    // Flags shown in the highest two LEDs.
    assign led[WIDTH-1 : WIDTH-2] = flags;

    // No dot on the 7-segment display.
    assign dp = 'b1;

    // Set active operation display to the following, with 'x' meaning we don't
    // care.
    //   hx0: SB for subtraction
    //   hx1: AD for addition
    //   hx2: CJ for bitwise and (conjunction)
    //   hx3: DJ for bitwise or (disjunction)
    //   hx4: ED for bitwise xor (exclusive disjunction)
    //   hx5: LD for load immediate to register
    //   hx6: nG for bitwise negation
    //   hx7: JP conditional jumps
    //   -- for unknown other (probably not implemented)
    //
    assign segments[0] = (active_op[3:0] == 'h0) ? 7'b0010010   // S
                         : (active_op[3:0] == 'h1) ? 7'b0001000 // A
                         : (active_op[3:0] == 'h2) ? 7'b1000110 // C
                         : (active_op[3:0] == 'h3) ? 7'b1000000 // D
                         : (active_op[3:0] == 'h4) ? 7'b0000110 // E
                         : (active_op[3:0] == 'h5) ? 7'b1000111 // L
                         : (active_op[3:0] == 'h6) ? 7'b0101011 // n
                         : (active_op[3:0] == 'h7) ? 7'b1110001 // J
                         : 7'b0111111;                          // -

    assign segments[1] = (active_op[3:0] == 'h0) ? 7'b0000000   // B
                         : (active_op[3:0] == 'h1) ? 7'b1000000 // D
                         : (active_op[3:0] == 'h2) ? 7'b1110001 // J
                         : (active_op[3:0] == 'h3) ? 7'b1110001 // J
                         : (active_op[3:0] == 'h4) ? 7'b1000000 // D
                         : (active_op[3:0] == 'h5) ? 7'b1000000 // D
                         : (active_op[3:0] == 'h6) ? 7'b0000010 // G
                         : (active_op[3:0] == 'h7) ? 7'b0001100 // P
                         : 7'b0111111;                          // -

    // We show "|-" if we're loading a value from a register.
    // "-" if the immediate value is the input to the operation.
    assign segments[2] = active_op[4] ? 7'b0001111 // |-
                         : 7'b0111111;             // -
    // Set to the register used. Some registers have no name.
    // Registers with name are:
    //   h0: A: general purpose
    //   h1: B: general purpose
    //   h2: C: general purpose
    //   h3: D: general purpose
    //   h4: Y: counter for loops
    //   h5: P: instruction pointer
    //   h6: S: stack pointer
    assign segments[3] = op_modifier_condition ?
                         // Jump condition
                         ((op_modifier == 'h0) ? 7'b1000000   // 0: zero
                          : (op_modifier == 'h1) ? 7'b1111001 // 1: non-zero
                          : (op_modifier == 'h2) ? 7'b0111111 // -: signed negative
                          : (op_modifier == 'h3) ? 7'b0110000 // 3: signed non-negative
                          : (op_modifier == 'h4) ? 7'b0011001 // 4: signed positive
                          : (op_modifier == 'h7) ? 7'b0010001 // Y: unconditional
                          : 7'b1111111)                       // space: unknown
                         // Register destination
                         : ((op_modifier == 'h0) ? 7'b0001000 // A
                          : (op_modifier == 'h1) ? 7'b0000000 // B
                          : (op_modifier == 'h2) ? 7'b1000110 // C
                          : (op_modifier == 'h3) ? 7'b1000000 // D
                          : (op_modifier == 'h4) ? 7'b0010001 // Y
                          : (op_modifier == 'h5) ? 7'b0001100 // P
                          : (op_modifier == 'h6) ? 7'b0010010 // S
                          : 7'b0111111);                      // -: unnamed

    reg [16:0] time_counter;
    // use time_counter to avoid overloading the 7-segment display.
    // We'll only actually run the loop code once every 2**16 clock cycles.
    // At 100MHz, this should make it run once every ~650 microseconds.
    always @(posedge clk) begin
        if (time_counter == 'b0) begin
            an = 4'b1111;
            an[3 - counter] = 1'b0;
            seg = segments[counter];
            counter = counter + 'b1;
        end
        time_counter = time_counter + 'b1;
    end

endmodule
