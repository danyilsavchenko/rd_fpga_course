`timescale 1ns / 1ps

module system_tb;

    logic       sys_clk = 1'b0;
    logic [3:0] btn     = 4'b0000;
    wire  [3:0] led_tri_o;

    integer pass_count = 0;
    integer fail_count = 0;

    time normal_period;
    time fast_period;
    time slow_period;

    // Simulation timing
    localparam time BUTTON_HOLD_TIME    = 30_000;    // 30 us
    localparam time BUTTON_RELEASE_TIME = 10_000;    // 10 us
    localparam time STOP_CHECK_TIME     = 30_000;    // 30 us
    localparam time GLOBAL_TIMEOUT      = 2_000_000; // 2 ms


    // PYNQ-Z2 external oscillator: 125 MHz -> 8 ns period
    always #4 sys_clk = ~sys_clk;


    system_wrapper dut (
        .sys_clk   (sys_clk),
        .btn       (btn),
        .led_tri_o (led_tri_o)
    );


    function automatic logic [3:0] next_forward(input logic [3:0] current);
        case (current)
            4'b0001: next_forward = 4'b0010;
            4'b0010: next_forward = 4'b0100;
            4'b0100: next_forward = 4'b1000;
            4'b1000: next_forward = 4'b0001; // Wrap around
            default: next_forward = 4'bxxxx;
        endcase
    endfunction


    function automatic logic [3:0] next_reverse(input logic [3:0] current);
        case (current)
            4'b0001: next_reverse = 4'b1000; // Wrap around
            4'b1000: next_reverse = 4'b0100;
            4'b0100: next_reverse = 4'b0010;
            4'b0010: next_reverse = 4'b0001;
            default: next_reverse = 4'bxxxx;
        endcase
    endfunction


    task automatic press_button(input integer button);
        begin
            $display(
                "[%0t] Pressing BTN%0d",
                $time,
                button
            );

            // Mechanical bounce on press
            btn[button] = 1'b1; #30;
            btn[button] = 1'b0; #20;
            btn[button] = 1'b1; #30;
            btn[button] = 1'b0; #20;

            // Keep button pressed long enough for:
            // debounce -> GPIO IRQ -> INTC -> MicroBlaze -> ButtonHandler()
            btn[button] = 1'b1;
            #(BUTTON_HOLD_TIME);

            // Mechanical bounce on release
            btn[button] = 1'b0; #30;
            btn[button] = 1'b1; #20;
            btn[button] = 1'b0; #30;
            btn[button] = 1'b1; #20;

            btn[button] = 1'b0;

            // Let release pass through debounce and GPIO interrupt handling
            #(BUTTON_RELEASE_TIME);
        end
    endtask


    task automatic expect_current_led(input logic [3:0] expected);
        begin
            if (led_tri_o === expected) begin
                pass_count++;

                $display(
                    "[%0t] PASS: LED = %b",
                    $time,
                    led_tri_o
                );
            end else begin
                fail_count++;

                $display(
                    "[%0t] FAIL: expected LED = %b, got %b",
                    $time,
                    expected,
                    led_tri_o
                );
            end
        end
    endtask


    task automatic expect_next_led(input logic [3:0] expected);
        begin
            wait (led_tri_o === expected);

            pass_count++;

            $display(
                "[%0t] PASS: LED changed to %b",
                $time,
                led_tri_o
            );
        end
    endtask


    task automatic check_forward_cycle;
        logic [3:0] expected;
        integer i;

        begin
            $display("\n--- Checking forward LED cycle ---");

            // Four transitions = one complete circle
            for (i = 0; i < 4; i++) begin
                expected = next_forward(led_tri_o);
                expect_next_led(expected);
            end
        end
    endtask


    task automatic check_reverse_cycle;
        logic [3:0] expected;
        integer i;

        begin
            $display("\n--- Checking reverse LED cycle ---");

            // Four transitions = one complete circle
            for (i = 0; i < 4; i++) begin
                expected = next_reverse(led_tri_o);
                expect_next_led(expected);
            end
        end
    endtask


    task automatic measure_led_period(output time period);
        logic [3:0] previous;
        time first_change;
        time second_change;

        begin
            previous = led_tri_o;

            wait (led_tri_o !== previous);
            first_change = $time;

            previous = led_tri_o;

            wait (led_tri_o !== previous);
            second_change = $time;

            period = second_change - first_change;

            $display(
                "[%0t] Measured LED period = %0t",
                $time,
                period
            );
        end
    endtask


    task automatic check_led_stopped;
        logic [3:0] stopped_led;

        begin
            stopped_led = led_tri_o;

            #(STOP_CHECK_TIME);

            if (led_tri_o === stopped_led) begin
                pass_count++;

                $display(
                    "[%0t] PASS: LED remained stopped at %b",
                    $time,
                    led_tri_o
                );
            end else begin
                fail_count++;

                $display(
                    "[%0t] FAIL: LED changed while stopped: %b -> %b",
                    $time,
                    stopped_led,
                    led_tri_o
                );
            end
        end
    endtask


    task automatic print_summary;
        begin
            $display("\n========================================");
            $display(" TEST SUMMARY");
            $display("========================================");
            $display(" PASS: %0d", pass_count);
            $display(" FAIL: %0d", fail_count);

            if (fail_count == 0)
                $display(" RESULT: ALL TESTS PASSED");
            else
                $display(" RESULT: TEST FAILED");

            $display("========================================\n");
        end
    endtask


    initial begin
        logic [3:0] previous_led;

        $timeformat(-9, 3, " ns", 10);

        $display("\n========================================");
        $display(" MicroBlaze LED controller test started");
        $display("========================================\n");


        // -----------------------------------------------------
        // 1. Firmware boot
        // -----------------------------------------------------

        wait (led_tri_o === 4'b0001);

        $display(
            "[%0t] Firmware boot detected: LED0 active",
            $time
        );

        expect_current_led(4'b0001);


        // -----------------------------------------------------
        // 2. Forward running-light cycle
        // -----------------------------------------------------

        check_forward_cycle();


        // -----------------------------------------------------
        // 3. Measure normal speed
        // -----------------------------------------------------

        $display("\n--- Measuring normal speed ---");

        measure_led_period(normal_period);


        // -----------------------------------------------------
        // 4. Stop
        // -----------------------------------------------------

        $display("\n--- BTN0: STOP ---");

        press_button(0);

        // press_button() already gives the ISR enough time to run
        check_led_stopped();


        // -----------------------------------------------------
        // 5. Resume
        // -----------------------------------------------------

        $display("\n--- BTN0: START ---");

        press_button(0);

        previous_led = led_tri_o;

        wait (led_tri_o !== previous_led);

        pass_count++;

        $display(
            "[%0t] PASS: running light resumed: %b -> %b",
            $time,
            previous_led,
            led_tri_o
        );


        // -----------------------------------------------------
        // 6. Change direction
        // -----------------------------------------------------

        $display("\n--- BTN1: CHANGE DIRECTION ---");

        press_button(1);

        check_reverse_cycle();


        // -----------------------------------------------------
        // 7. Faster
        // -----------------------------------------------------

        $display("\n--- BTN2: FASTER ---");

        press_button(2);

        measure_led_period(fast_period);

        if (fast_period < normal_period) begin
            pass_count++;

            $display(
                "[%0t] PASS: faster period %0t < normal period %0t",
                $time,
                fast_period,
                normal_period
            );
        end else begin
            fail_count++;

            $display(
                "[%0t] FAIL: faster period %0t >= normal period %0t",
                $time,
                fast_period,
                normal_period
            );
        end


        // -----------------------------------------------------
        // 8. Slower
        // -----------------------------------------------------

        $display("\n--- BTN3: SLOWER ---");

        press_button(3);

        measure_led_period(slow_period);

        if (slow_period > fast_period) begin
            pass_count++;

            $display(
                "[%0t] PASS: slower period %0t > fast period %0t",
                $time,
                slow_period,
                fast_period
            );
        end else begin
            fail_count++;

            $display(
                "[%0t] FAIL: slower period %0t <= fast period %0t",
                $time,
                slow_period,
                fast_period
            );
        end


        // -----------------------------------------------------
        // 9. Final forward/reverse sanity is implicit above
        // -----------------------------------------------------

        print_summary();
        $finish;
    end


    // Catch firmware, interrupt or testbench deadlock
    initial begin
        #(GLOBAL_TIMEOUT);

        fail_count++;

        $display(
            "\n[%0t] FAIL: GLOBAL SIMULATION TIMEOUT",
            $time
        );

        print_summary();
        $finish;
    end

endmodule