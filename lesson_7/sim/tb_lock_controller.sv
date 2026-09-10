`timescale 1ns / 1ps

module tb_lock_controller;
    reg clk;
    reg rst;

    reg [3:0] digit_in;
    wire unlocked_led;

    localparam CLK_PERIOD = 10; // Clock period in ns
    
    localparam [3:0] CORRECT_SEQUENCE [0:2] = '{4'd5, 4'd3, 4'd7}; // Correct sequence of digits
    localparam [3:0] INCORRECT_SEQUENCE [0:2] = '{4'd5, 4'd10, 4'd7}; // Incorrect sequence of digits

    localparam led_ok = 1'b1; // Expected value of unlocked_led for correct sequence

    // Instantiate the Unit Under Test (UUT)
    lock_controller uut (
        .clk(clk), 
        .rst(rst), 
        .digit_in(digit_in), 
        .unlocked_led(unlocked_led)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        digit_in = 4'b0000;
    end

    always #(CLK_PERIOD/2) clk = ~clk; // Clock generation

    task automatic wait_n_clocks(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask

    task automatic check_unlocked_led(input string test_name, input expected);
        begin
            if (unlocked_led === expected) begin
                $display("[PASS] %s", test_name);
            end else begin
                $display("[FAIL] %s, unlocked_led = %b, expected = %b", test_name, unlocked_led, expected);
            end
        end
    endtask

    task automatic input_digit(input [3:0] digit);
        begin
            digit_in = digit;
            wait_n_clocks(1); #1;
        end
    endtask

    task automatic test_lock_controller(input [3:0] d1, input [3:0] d2, input [3:0] d3, input expected_led);
        begin
            $display("Testing lock controller with input sequence: [%d %d %d]", d1, d2, d3);
            rst = 1;
            wait_n_clocks(1); #1;
            rst = 0;

            input_digit(d1);
            input_digit(d2);
            input_digit(d3);

            check_unlocked_led($sformatf("Input sequence [%d %d %d]", d1, d2, d3), expected_led);
        end
    endtask

    initial begin
        $display("Starting lock controller testbench...");

        wait_n_clocks(3); #1;
        rst = 0;

        // Test case 1: Correct sequence
        test_lock_controller(CORRECT_SEQUENCE[0], CORRECT_SEQUENCE[1], CORRECT_SEQUENCE[2], led_ok); // Expected unlocked_led = 1

        wait_n_clocks(3); #1;

        rst = 1;
        wait_n_clocks(3); #1;

        // Test case 2: Incorrect sequence
        test_lock_controller(INCORRECT_SEQUENCE[0], INCORRECT_SEQUENCE[1], INCORRECT_SEQUENCE[2], led_ok); // Expected unlocked_led = 0

        wait_n_clocks(3); #1;

        $display("Lock controller testbench completed.");
        $finish;
    end

endmodule