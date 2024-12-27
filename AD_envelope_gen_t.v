`timescale 1ns / 1ps

module AD_envelope_gen_t(

    );
    
    reg clk;
    reg rst;
    wire sample_tick;
    reg [15:0]attack_time;
    reg [15:0]decay_time;
    reg [6:0] amplitude;
    reg note_pressed;
    wire [7:0]envelope;
    
    AD_envelope_gen ad(
        clk,
        rst,
        sample_tick,
        attack_time,
        decay_time,
        amplitude,
        note_pressed,
        envelope
    );
    
    reg [31:0] num;
    
    clock_divider cd(
    clk,
    rst,
    num,
    sample_tick
    );
    
    parameter cyc = 10;
    always #cyc clk <= ~clk;

    
    initial begin
        clk <= 1'b1;
        rst <= 1'b1;
        attack_time <= 16'd8;
        decay_time <= 16'd4;
        amplitude <= 7'd99;
        note_pressed <= 1'b0;
        num <= 16'd10;
        
        @(negedge clk) rst = 1'b0;
        @(negedge clk) rst = 1'b1;
        
        #(3 * cyc) note_pressed = 1'b1;
        #(50 * cyc) note_pressed = 1'b0;
        
        #10000;
        
        amplitude = 7'd63;
        attack_time <= 16'd128;
        decay_time <= 16'd0;
        
        note_pressed <= 1'b1;
        
        #50 note_pressed <= 1'b0;
    end
    
endmodule
