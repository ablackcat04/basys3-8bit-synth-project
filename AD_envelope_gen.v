`timescale 1ns / 1ps

module AD_envelope_gen(
    input clk,
    input rst,
    input sample_tick,
    input [15:0]attack_time,
    input [15:0]decay_time,
    input [6:0] amplitude,
    input note_pressed,
    output [7:0]envelope
    );
    wire note_start;
    one_pulse op1(clk, note_pressed, note_start);
    
    wire state_transition;
    reg [15:0] sample_count;
    
    reg [1:0] state;
    wire [1:0] next_state;
    
    parameter attack = 2'd0;
    parameter decay = 2'd1;
    parameter idle = 2'd2;
    
    assign state_transition = (sample_count >= attack_time && state == attack) || (sample_count >= decay_time && state == decay) || note_start;
        
    assign next_state = note_start ? attack : (state + 2'd1);
    
    always @(posedge clk) begin
        if (~rst) begin
            state <= idle;
        end else begin
            if (state_transition)
                state <= next_state;
            else
                state <= state;
        end
        
        if (~rst || state_transition) begin
            sample_count <= 16'd0;
        end else begin
            if (sample_tick) begin
                sample_count <= sample_count + 16'd1;
            end else begin
                sample_count <= sample_count;
            end
        end
        
    end
    
    reg [11:0] ve;
    
    always @(posedge clk) begin
        if (~rst) begin
            ve <= 8'd0;
        end else begin
            if (sample_tick) begin
                if (state == attack)
                    ve <= amplitude * sample_count / attack_time;
                else if (state == decay)
                    ve <= amplitude * (decay_time - sample_count) / decay_time;
                else
                    ve <= 8'd0;
            end else begin
                ve <= ve;
            end
        end
    end
    
    assign envelope = ve > 8'd255 ? 8'd255 : ve[7:0];
    
endmodule
