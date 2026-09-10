//     create_clock -period 4.000 -name sys_clk [get_ports clk]
module logic_func_pipe (
    input wire clk,
    input wire rst,                  //active - high, asynchronous
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [7:0] c,
    input wire [7:0] d,
    input wire [7:0] e,
    output reg [15:0] result
);

    reg [7:0] a_reg, b_reg, c_reg, d_reg, e_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg <= 8'd0;
            b_reg <= 8'd0;
            c_reg <= 8'd0;
            d_reg <= 8'd0;
            e_reg <= 8'd0;
        end else begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
            d_reg <= d;
            e_reg <= e;
        end 
    end

    reg [15:0] intermediate_result_1;
    reg [15:0] intermediate_result_2;
    reg [15:0] intermediate_result_3;
    reg [7:0] intermediate_e_1;
    reg [7:0] intermediate_e_2;
    
    

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            intermediate_result_1 <= 16'd0;
            intermediate_result_2 <= 16'd0;
            intermediate_e_1 <= 8'd0;
        end else begin
            intermediate_result_1 <= (a_reg + b_reg);
            intermediate_result_2 <= (c_reg - d_reg);
            intermediate_e_1 <= e_reg;
        end
    end

    // stage 2

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            intermediate_e_2 <= 8'd0;
            intermediate_result_3 <= 16'd0;
        end else begin
            intermediate_result_3 <= intermediate_result_1 * intermediate_result_2;
            intermediate_e_2 <= intermediate_e_1;
        end
    end
    
    //stage 3
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 16'd0;
        end else begin
            result <= intermediate_result_3 ^ intermediate_e_2;
        end
    end
    
    

endmodule