`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RD FPGA training
// Engineer: D.Savchenko
// Create Date: 08/29/2026 20:39:07 PM
// Design Name: 
// Module Name: counter
////////////////////////////////////////////////////////////////////////////////

module counter (
    input wire clk,
    input wire rst,             //active - high, asynchronous
    input wire load,            //sync load data into counter
    input wire up_down,         //1 - up, 0 - down
    input wire en,              //enable counting
    input wire [3:0] data_in,   //data to load into counter
    output reg [3:0] count      //counter value
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 4'b0000; // Reset counter to 0
        end else if (load) begin
            count <= data_in; // Load data into counter
        end else if (en && up_down) begin
            if (count == 4'b1111) begin
                count <= 4'b0000; // Wrap around to 0 when counting up
            end else begin
                count <= count + 1; // Count up
            end
        end else if (en && !up_down) begin
            if (count == 4'b0000) begin
                count <= 4'b1111; // Wrap around to 15 when counting down
            end else begin
                count <= count - 1; // Count down
            end
        end else if (en) begin
            count <= count - 1; // Count down
        end else begin
            count <= count; // Hold current value
        end
    end

endmodule