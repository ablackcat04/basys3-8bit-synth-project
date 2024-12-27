`timescale 1ns / 1ps

module triangle_wave_gen(
    input clk,
    input rst,
    input sample_tick,
    input [15:0]wave_length, // in samples, sampleing rate 20kHz
    input [6:0]amplitude,
    output [7:0]out
    );
    
    wire [15:0] first_half_length;
    wire [15:0] second_half_length;
    
    assign first_half_length = wave_length >> 1;
    assign second_half_length = wave_length - first_half_length;
    
    wire state_transition;
    reg state;
    reg [15:0]sample_count;
    
    parameter up = 1'b0;
    parameter down = 1'b1;
    
    always @(posedge clk) begin
        if (state_transition || ~rst) begin
            sample_count <= 16'd0;
        end else begin
            if (sample_tick) 
                sample_count <= sample_count + 16'd1;
            else
                sample_count <= sample_count;
        end
        
        
        if (~rst) begin
            state <= up;
        end else begin
            if (state_transition)
                state <= ~state;
            else
                state <= state;
        end
    end
    
    assign state_transition = (sample_count >= first_half_length && state == up) || (sample_count >= second_half_length && state == down);
    assign out = (state == up)? (sample_count * amplitude * 2 / first_half_length) + (8'd127 - amplitude) : ((second_half_length - sample_count)* amplitude * 2 / second_half_length) + (8'd127 - amplitude);
    
    
endmodule
