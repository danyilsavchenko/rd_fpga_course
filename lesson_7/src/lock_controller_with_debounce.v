module lock_controller_with_debounce (
    input clk,
    input rst,                  //active - high, asynchronous
    input [3:0] digit_in,       //4-bit code input
    output unlocked_led         //active high, indicates if the lock is unlocked
);

    wire [3:0] debounced_digit_in;

    debounce #(
        .WIDTH(4),
        .CLK_PERIOD(20)
    ) debounce_inst (
        .clk(clk),
        .in(digit_in),
        .out(debounced_digit_in)
    );

    lock_controller lock_controller_inst (
        .clk(clk),
        .rst(rst),
        .digit_in(debounced_digit_in),
        .unlocked_led(unlocked_led)
    );

endmodule