module debounce #(
    parameter DEBOUNCE_CYCLES = 1_000_000,
    parameter WIDTH = 4
)(
    input                   clk,
    input                   rst,
    input       [WIDTH-1:0] btn_in,
    output reg  [WIDTH-1:0] btn_out
);

`ifdef SIMULATION
    localparam integer ACTIVE_DEBOUNCE_CYCLES = 20;
`else
    localparam integer ACTIVE_DEBOUNCE_CYCLES = DEBOUNCE_CYCLES;
`endif

    localparam integer COUNTER_WIDTH = (ACTIVE_DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(ACTIVE_DEBOUNCE_CYCLES);

    // Synchronizer
    reg [WIDTH-1:0] sync_0;
    reg [WIDTH-1:0] sync_1;

    // One counter for every button
    reg [COUNTER_WIDTH-1:0] counter [0:WIDTH-1];

    integer i;

    // ---------------------------------------------------------
    // 2-FF synchronizer
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            sync_0 <= {WIDTH{1'b0}};
            sync_1 <= {WIDTH{1'b0}};
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end
    end

    // ---------------------------------------------------------
    // Debounce
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            btn_out <= {WIDTH{1'b0}};

            for (i = 0; i < WIDTH; i = i + 1)
                counter[i] <= {COUNTER_WIDTH{1'b0}};

        end else begin

            for (i = 0; i < WIDTH; i = i + 1) begin

                // Input agrees with current accepted state
                if (sync_1[i] == btn_out[i]) begin
                    counter[i] <= {COUNTER_WIDTH{1'b0}};

                end else begin

                    // Input has been different long enough
                    if (counter[i] == ACTIVE_DEBOUNCE_CYCLES - 1) begin
                        btn_out[i] <= sync_1[i];
                        counter[i] <= {COUNTER_WIDTH{1'b0}};

                    end else begin
                        counter[i] <= counter[i] + 1'b1;
                    end

                end
            end
        end
    end

endmodule