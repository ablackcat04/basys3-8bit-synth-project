`timescale 1ns / 1ps
`timescale 1ns / 1ps

module pulse_wave_gen(
    input clk,
    input rst,
    input sample_tick,
    input [15:0]wave_length, // in samples, sampleing rate 20kHz
    input [6:0]amplitude,
    input [5:0] duty,
    output [7:0]out
    );
    
    wire [15:0] high_length;
    wire [15:0] low_length;
    
    assign high_length = (wave_length * duty) >> 6;
    assign low_length = wave_length - high_length;
    
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
    
    assign state_transition = (sample_count >= high_length && state == up) || (sample_count >= low_length && state == down);
    assign out = (state == down)? (8'd127 - amplitude) : (8'd127 + amplitude);
    
    
endmodule
