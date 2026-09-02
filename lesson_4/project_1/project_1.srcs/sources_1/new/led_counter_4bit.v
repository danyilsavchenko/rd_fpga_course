`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RD FPGA training
// Engineer: D.Savchenko
// 
// Create Date: 08/29/2026 04:54:07 PM
// Design Name: 
// Module Name: led_counter_4bit
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

module led_counter_4bit #(
    parameter LED_ACTIVE = 1
)(
    input i_clk,
    input i_rst_n,

    output [3:0] o_led
);

    reg [3:0] r_counter = 0;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_counter <= 0;
        end else begin
            if (r_counter == 4'b1111) begin
                r_counter <= 0;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end

    assign o_led = (LED_ACTIVE) ? r_counter : ~r_counter;


endmodule