`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 05:21:05 PM
// Design Name: 
// Module Name: tb_led_counter_4bit
// Project Name: 
// Target Devices: 
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


module tb_led_counter_4bit;

    // parameters
    localparam LED_ACTIVE = 1;
    
    // Inputs
    reg r_clk;
    reg r_rst_n;

    // Outputs
    wire [3:0] w_led;

    //cycle counter
    integer i = 0; 

    // Instantiate the Unit Under Test (UUT)
    led_counter_4bit #(.LED_ACTIVE(LED_ACTIVE)) uut (
        .i_clk(r_clk),
        .i_rst_n(r_rst_n),
        .o_led(w_led)
    );

    // Clock generation
    initial begin
        r_clk = 0;
        forever #5 r_clk = ~r_clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        r_rst_n = 0;

        // Wait for global reset to finish
        #20;
        
        r_rst_n = 1; // Release reset

        // Run the simulation for a certain number of clock cycles
        for (i = 0; i < 40; i = i + 1) begin
            #10; // Wait for one clock cycle (10ns)
            $display("Time: %0dns, LED Output: %b", $time, w_led);
        end

        $finish; // End simulation
    end
endmodule