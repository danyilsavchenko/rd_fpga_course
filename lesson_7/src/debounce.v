module debounce #(
    parameter WIDTH = 1, 
    parameter CLK_PERIOD = 20
) (
    input clk,
    input [WIDTH-1:0] in,       //input signal to be debounced
    output reg [WIDTH-1:0] out  //debounced output signal
);

    reg [$clog2(CLK_PERIOD)-1:0] counter [WIDTH-1:0]; //counter for each bit of the input
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (in[i] == out[i]) begin
                counter[i] <= {$clog2(CLK_PERIOD){1'b0}}; // reset counter if input matches output
            end else begin
                counter[i] <= counter[i] + 1'b1; // increment counter if input differs from output
                if (counter[i] == {$clog2(CLK_PERIOD){1'b1}}) begin
                    out[i] <= in[i]; // update output when counter reaches max value
                end
            end
        end
    end

endmodule