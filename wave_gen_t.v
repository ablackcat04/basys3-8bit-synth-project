`timescale 1ns / 1ps

module wave_gen_t(

    );
    
    reg clk;
    reg rst;
    wire sample_tick;
    reg [15:0]wave_length; // in samples
    reg [6:0]amplitude;
    reg [5:0] duty;
    wire [7:0]pulse;
    wire [7:0]triangle;
    
    reg [31:0] num;
    
    clock_divider cd(
    clk,
    rst,
    num,
    sample_tick
    );
    
    pulse_wave_gen pwg(
    clk,
    rst,
    sample_tick,
    wave_length, // in samples
    amplitude,
    duty,
    pulse
    );
    
    triangle_wave_gen twg(
    clk,
    rst,
    sample_tick,
    wave_length, // in samples, sampleing rate 20kHz
    amplitude,
    triangle
    );
    
    wire [7:0] mixer_out;
    wire out;
    
    mixer mx(
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .in0(pulse),
        .in1(triangle),
        .in2(8'd127),
        .in3(8'd127),
        .out(mixer_out)
    );
    
    PWM_gen audio_out(
        .clk(clk),
        .rst(rst),
        .duty(mixer_out),
        .PWM(out)
    );
    
    parameter cyc = 10;
    always #cyc clk <= ~clk;
    
    always @(posedge sample_tick) begin
        $display("%d", out);
    end
    
    initial begin
        clk <= 1'b1;
        rst <= 1'b1;
        wave_length <= 16'd24;
        amplitude <= 7'd63;
        duty <= 6'd32;
        num <= 32'd4098;
        
        @(negedge clk) rst <= 1'b0;
        #100;
        @(negedge clk) rst <= 1'b1;
        
        #1000000;
        
        amplitude <= 7'd0;
        
        #100000;
        
        wave_length <= 16'd12;
        amplitude <= 7'd63;
        duty <= 6'd16;
        
        #2000000;
        
        
    end
    
endmodule
