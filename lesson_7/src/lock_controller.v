// code 5 3 7

module lock_controller (
    input clk,
    input rst,                  //active - high, asynchronous
    input [3:0] digit_in,       //4-bit code input
    output unlocked_led         //active high, indicates if the lock is unlocked
);

    localparam [3:0] CODE_0 = 4'd5;
    localparam [3:0] CODE_1 = 4'd3;
    localparam [3:0] CODE_2 = 4'd7;

    localparam [1:0]    LOCKED = 2'b00,
                        WAIT_D2 = 2'b01,
                        WAIT_D3 = 2'b10,
                        UNLOCKED = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= LOCKED;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state; // default to current state
        case (state)
            LOCKED: begin
                if (digit_in == CODE_0) begin 
                    next_state = WAIT_D2;
                end else begin
                    next_state = LOCKED;
                end
            end

            WAIT_D2: begin
                if (digit_in == CODE_1) begin 
                    next_state = WAIT_D3;
                end else begin 
                    next_state = LOCKED;
                end
            end

            WAIT_D3: begin
                if (digit_in == CODE_2) begin 
                    next_state = UNLOCKED;
                end else begin
                    next_state = WAIT_D3;
                end
            end

            UNLOCKED: begin
                next_state = UNLOCKED; // stay unlocked until reset
            end

        endcase
    end 


    assign unlocked_led = (state == UNLOCKED);

    
endmodule