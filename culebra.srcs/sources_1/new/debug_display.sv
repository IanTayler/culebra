`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Computer Wit SAS
// Engineer: Ian Tayler
//
// Create Date: 02/22/2022 02:18:45 PM
// Design Name: culebra
// Module Name: debug_display
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


module debug_display
    #(parameter WIDTH = 8)
    (
        output reg [6:0]         seg,
        output wire              dp,
        output reg [3:0]         an,
        output wire [15:0]       led,
        input wire [WIDTH-1 : 0] reg_page[0:7],
        input wire [2:0]         active_reg,
        input wire [4:0]         active_op,
        input wire [1:0]         flags,
        input wire               clk
    );

    wire [6:0] segments [0:3];
    reg [1:0] counter;

    // Show active register value in leds. Ignore highest two bits to
    // show the flags instead.
    assign led[WIDTH-3 : 0] = reg_page[active_reg];
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
    //   hx7: JP conditional jumps high bits define condition
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
    assign segments[3] = (active_reg == 'h0) ? 7'b0001000   // A
                         : (active_reg == 'h1) ? 7'b0000000 // B
                         : (active_reg == 'h2) ? 7'b1000110 // C
                         : (active_reg == 'h3) ? 7'b1000000 // D
                         : (active_reg == 'h4) ? 7'b0010001 // Y
                         : (active_reg == 'h5) ? 7'b0001100 // P
                         : (active_reg == 'h6) ? 7'b0010010 // S
                         : 7'b0111111;                      // -

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
