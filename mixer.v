`timescale 1ns / 1ps

module mixer(
    input clk,
    input rst,
    input sample_tick,
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    output reg [7:0] out
    );
    
    reg [9:0] mixed_value;
    wire [7:0] next_value;
    
    wire [9:0] sum;
    
    assign sum = ((in0 + in1) + (in2 + in3));
    
    always @(posedge clk) begin
        if (~rst) begin
            mixed_value <= 10'd0;
            out <= 8'd127;
        end else begin
            mixed_value <= (sum > 10'd381)? sum - 10'd381 : 10'd0;
            out <= sample_tick ? next_value : out;
        end
    end
    
    assign next_value = (mixed_value > 10'd255)? 8'd255 : mixed_value[7:0];    
    
endmodule
