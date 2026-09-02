`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Company: RD FPGA training
// Engineer: D.Savchenko
// Create Date: 08/29/2026 20:39:07 PM
// Design Name: 
// Module Name: tb_counter
////////////////////////////////////////////////////////////////////////////////

module tb_counter;

    // Inputs
    reg clk;
    reg rst;
    reg load;
    reg up_down;
    reg en;
    reg [3:0] data_in;

    // Outputs
    wire [3:0] count;

    parameter CLK_PERIOD = 10; // Clock period in ns
    parameter COUNTER_WIDTH = 4; // Width of the counter
    localparam MAX_COUNT = {COUNTER_WIDTH{1'b1}}; // Maximum count value

    // Instantiate the Unit Under Test (UUT)
    counter uut (
        .clk(clk), 
        .rst(rst), 
        .load(load), 
        .up_down(up_down), 
        .en(en), 
        .data_in(data_in), 
        .count(count)
    );

    task automatic wait_n_clocks(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask

    task automatic check_count(input string test_name, input [3:0] expected);
        begin
            if (count === expected) begin
                $display("[PASS] %s", test_name);
            end else begin
                $display("[FAIL] %s, count = %d, expected = %d", test_name, count, expected);
            end
        end
    endtask

    //load task
    task automatic load_counter(input [3:0] data);
        begin
            rst = 1;
            wait_n_clocks(1); #1;
            rst = 0;

            load = 1;
            data_in = data;
            wait_n_clocks(1); #1;

            load = 0;
            
            check_count("counter load", data);

        end
    endtask

    //up counting task
    task automatic count_up(input [3:0] data);
        integer need_steps;
        integer i;
        begin
            need_steps = MAX_COUNT - data + 1; // Calculate the number of steps to reach MAX_COUNT and wrap around
            
            load_counter(data);
            wait_n_clocks(1); #1; // Wait for one clock cycle after loading

            en = 1;
            up_down = 1; // Set to count up

            for (i = 1; i <= need_steps; i = i + 1) begin
                wait_n_clocks(1);
                #1;

                if (count === (data + i) % (MAX_COUNT + 1)) begin
                    if (count === 4'd0) begin
                        $display(
                            "[PASS] Counter up: value wrapped around to 0 as expected"
                        );
                    end else begin
                        if (count === data + i) begin
                            $display(
                                "[PASS] Counter up: value incremented correctly to %d",
                                count
                            );
                        end else begin
                            $display(
                                "[FAIL] Counter up: Expected count = %d, but got %d",
                                (data + i) % (MAX_COUNT + 1),
                                count
                            );
                        end
                    end
                end
            end
        end
    endtask

    task automatic count_down(input [3:0] data);
        integer need_steps;
        integer expected_count;
        integer i;
        begin
            need_steps = data + 1; // Calculate the number of steps to reach 0 and wrap around
            
            load_counter(data);
            wait_n_clocks(1); #1; // Wait for one clock cycle after loading

            en = 1;
            up_down = 0; // Set to count down

            for (i = 1; i <= need_steps; i = i + 1) begin
                wait_n_clocks(1);
                #1;

                if (i <= data) begin
                    expected_count = data - i;
                end else begin
                    expected_count = MAX_COUNT;
                end

                if (count === expected_count) begin
                    if (count === MAX_COUNT) begin
                    $display(
                        "[PASS] Counter down: value wrapped around to %d as expected",
                        MAX_COUNT
                    );
                    end else begin
                        $display(
                            "[PASS] Counter down: value decremented correctly to %d",
                            count
                        );
                    end
                end else begin
                    $display(
                        "[FAIL] Counter down: Expected count = %d, but got %d",
                        expected_count,
                        count
                    );
                end
            end
        end
    endtask

    task automatic hold_counter(input [3:0] data);
        begin
            load_counter(data);

            up_down = 1; // Set to count up (should not matter since en=0)
            en = 0; // Disable counting

            wait_n_clocks(3); #1; // Wait for one clock cycle after loading

            check_count("counter hold", data);
        end
    endtask 

    task automatic load_priority (input [3:0] data);
        begin
            load = 1;
            data_in = data;

            en = 1; // Enable counting
            up_down = 1; // Set to count up

            wait_n_clocks(1); #1; // Wait for one clock cycle

            check_count("load priority", data);

        end
    endtask


    // clock generation

    initial begin
        clk = 0;
    end

    always begin
        #(CLK_PERIOD/2) clk = ~clk; // 10ns clock period
    end



    initial begin
        $display("Starting counter simulation...");

        // Initialize Inputs
        wait_n_clocks(1); #1; // Wait for one clock cycle
        rst = 0;
        load = 0;
        up_down = 1;
        en = 0;
        data_in = 4'b0000;  

        $display("Testing load functionality...");
        load_counter(4'd10); // Load 10 into the counter

        wait_n_clocks(2); #1; // Wait for 2 clock cycles

        $display("Testing count up functionality...");
        count_up(4'd10); // Start counting up from 10

        wait_n_clocks(2); #1; // Wait for 2 clock cycles

        $display("Testing hold functionality...");
        hold_counter(4'd5); // Hold the counter at 5

        $display("Testing count down functionality...");
        count_down(4'd5); // Start counting down from 5

        $display("Testing load priority functionality...");
        load_priority(4'd7); // Load 7 into the counter while counting up

        $display("Counter simulation completed.");

        $finish; // End simulation
    end
    
endmodule