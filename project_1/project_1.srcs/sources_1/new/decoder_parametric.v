`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RD FPGA training
// Engineer: D.Savchenko
// 
// Create Date: 08/29/2026 04:54:07 PM
// Design Name: 
// Module Name: decoder_parametric
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


module decoder_parametric #(
    parameter WIDTH = 4
)(
    input [WIDTH-1:0]       i_addr,
    input                   i_en,       //active high
    
    output [2**WIDTH-1:0]   o_decoded
);

    assign o_decoded = (i_en) ? (1 << i_addr) : 0;

endmodule
