`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RD FPGA training
// Engineer: D.Savchenko
// 
// Create Date: 08/29/2026 04:54:07 PM
// Design Name: 
// Module Name: mux_2to1
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


module mux_2to1 (
    input i_sel,
    input [1:0] i_data,
    output reg o_data
);

    always @(*) begin
        case (i_sel)
            
            1'b0: o_data = i_data[0];
            1'b1: o_data = i_data[1];
        endcase
    end

endmodule