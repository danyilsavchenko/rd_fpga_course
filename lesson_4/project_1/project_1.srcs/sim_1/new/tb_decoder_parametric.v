`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 05:21:05 PM
// Design Name: 
// Module Name: tb_decoder_parametric
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


module tb_decoder_parametric;

    localparam WIDTH_4 = 4;     
    localparam WIDTH_8 = 8;     

    // Inputs
    reg r_en_4;
    reg r_en_8;
    reg [WIDTH_4-1:0] r_addr_4; // 4-bit address input
    reg [WIDTH_8-1:0] r_addr_8; // 8-bit address input

    // Outputs
    wire [2**WIDTH_4-1:0] w_decoded_4;
    wire [2**WIDTH_8-1:0] w_decoded_8;

    //cycle counter
    integer i = 0; 
    
    // expected vectors for comparisons
    reg [2**WIDTH_4-1:0] r_expected_4;
    reg [2**WIDTH_8-1:0] r_expected_8;

    // test results (start as passed, fail on any mismatch)
    integer test_passed_4 = 1;
    integer test_passed_8 = 1;

    // Instantiate the Unit Under Test (UUT) for WIDTH = 4
    decoder_parametric #(
        .WIDTH(WIDTH_4)
    ) uut_4 (
        .i_addr(r_addr_4),
        .i_en(r_en_4),
        .o_decoded(w_decoded_4)
    );

    // Instantiate the Unit Under Test (UUT) for WIDTH = 8
    decoder_parametric #(
        .WIDTH(WIDTH_8)
    ) uut_8 (
        .i_addr(r_addr_8),
        .i_en(r_en_8),
        .o_decoded(w_decoded_8)
    );

    initial begin
        //Inputs init
        r_en_4 <= 0;      //disable decoder (width 4)
        r_en_8 <= 0;      //disable decoder (width 8)
        r_addr_4 <= 0;
        r_addr_8 <= 0;
        r_expected_4 <= 0;
        r_expected_8 <= 0;

        // Test for WIDTH = 4

        #10; // Wait 10 ns
        r_en_4 <= 1;      //enable decoder 4
        #10; // Wait 10 ns

        for (i = 0; i < 2**WIDTH_4; i = i + 1) begin
            r_addr_4 = i; // set address (blocking)
            #10; // Wait 10 ns for output to settle
            r_expected_4 = 0;
            r_expected_4[i] = 1'b1;
            if (w_decoded_4 !== r_expected_4) begin
                $display("Test failed for WIDTH=4 at address %d: expected %b, got %b", i, r_expected_4, w_decoded_4);
                test_passed_4 = 0;
            end
        end

        r_en_4 = 0; //disable decoder 4
        r_addr_4 = 0; //reset address

        // Test for WIDTH = 8

        #10; // Wait 10 ns
        r_en_8 <= 1;      //enable decoder 8
        #10; // Wait 10 ns

        for (i = 0; i < 2**WIDTH_8; i = i + 1) begin
            r_addr_8 = i; // set address (blocking)
            #10; // Wait 10 ns for output to settle
            r_expected_8 = 0;
            r_expected_8[i] = 1'b1;
            if (w_decoded_8 !== r_expected_8) begin
                $display("Test failed for WIDTH=8 at address %d: expected %b, got %b", i, r_expected_8, w_decoded_8);
                test_passed_8 = 0;
            end
        end

        r_en_8 = 0;    //disable decoder 8
        r_addr_8 = 0;  //reset address

        #10;

        $display("\n <===================== TEST RESULTS ==================== >");
        $display("Test for WIDTH=4 %s", test_passed_4 ? "PASSED" : "FAILED");
        $display("Test for WIDTH=8 %s", test_passed_8 ? "PASSED" : "FAILED");

        $finish;
    end



endmodule
