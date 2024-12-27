`timescale 1ns / 1ps

module synth_top(
    input clk,
    input rst,
    input btnL,
    input [15:0] sw,
    output [3:0] led,
	output pmod_1,	//AIN
	output pmod_2,	//GAIN
	output pmod_4	//SHUTDOWN_N
    );
    
    wire trigger_noise;
    debounce dn(trigger_noise, btnL, clk);
    
    assign led = sw[3:0];
    
    assign pmod_2 = 1'd1;	//no gain(6dB)
    assign pmod_4 = 1'd1;	//turn-on
    
    wire sample_tick;
    wire noise_tick;
    
    wire rst_n;
    
    button br(clk, rst, rst_n);

    clock_divider cd(
        clk,
        rst_n,
        16'd1024,
        sample_tick
    );
    
    clock_divider cdn(
        clk,
        rst_n,
        {16'd0, 16'b1110_1110_0110_0001},
        noise_tick
    );
    
    wire wnotecd, wnotecd2;
    
    clock_divider cdnote(
        clk,
        rst_n,
        32'd25_000_000,
        wnotecd
    );
    
    clock_divider cdnote2(
        clk,
        rst_n,
        32'd12_500_000,
        wnotecd2
    );
    
    reg [15:0] pulse1_wave_len;
    reg [15:0] pulse2_wave_len;
    reg [15:0] tri_wave_len;
    
    parameter [0:31] score_amp1 = 32'b1111_1111_1111_1111_0000_0000_0000_0000;
    parameter [0:31] score_amp2 = 32'b1000_0010_1000_0000_0000_0000_0000_0000;
    
    reg [4:0] score_ptr;
    
    always @(posedge clk) begin
        if (score_ptr == 5'd0) begin
            pulse2_wave_len <= 16'd148;
        end else begin
            pulse2_wave_len <= 16'd187;
        end
    
        if (~rst_n) begin
            tri_wave_len <= 16'd1493;
        end else begin
            if (wnotecd) begin
                if (tri_wave_len == 16'd747) begin
                    tri_wave_len <= 16'd1493;
                end else begin
                    tri_wave_len <= 16'd747;
                end
            end else begin
                tri_wave_len <= tri_wave_len;
            end
        end
        
        if (~rst_n) begin
            pulse1_wave_len <= 16'd373;
        end else begin
            if (wnotecd2) begin
                if (pulse1_wave_len == 16'd373) begin
                    pulse1_wave_len <= 16'd333;
                end else if (pulse1_wave_len == 16'd333) begin
                    pulse1_wave_len <= 16'd296;
                end else if (pulse1_wave_len == 16'd296) begin
                    pulse1_wave_len <= 16'd249;
                end else begin
                    pulse1_wave_len <= 16'd373;
                end
            end else begin
                pulse1_wave_len <= pulse1_wave_len;
            end
        end
        
        if (~rst_n) begin
            score_ptr <= 5'd0;
        end else begin
            if (wnotecd2) begin
                score_ptr <= score_ptr + 5'd1;
            end else begin
                score_ptr <= score_ptr;
            end
        end
    end
    
    wire [7:0] pulse1_out;
    wire [7:0] pulse2_out;
    wire [7:0] triangle_out;
    wire [7:0] noise_out;
    wire [7:0] mixer_out;
    
    pulse_wave_gen pwg1(
        .clk(clk),
        .rst(rst_n),
        .sample_tick(sample_tick),
        .wave_length(pulse1_wave_len), // in samples
        .amplitude(7'd7 * score_amp1[score_ptr]),
        .duty(31),
        .out(pulse1_out)
    );
    
    pulse_wave_gen pwg2(
        .clk(clk),
        .rst(rst_n),
        .sample_tick(sample_tick),
        .wave_length(pulse2_wave_len), // in samples
        .amplitude(7'd15 * score_amp2[score_ptr]),
        .duty(8),
        .out(pulse2_out)
    );
    
    triangle_wave_gen twg(
        .clk(clk),
        .rst(rst_n),
        .sample_tick(sample_tick),
        .wave_length(tri_wave_len), // in samples, sampleing rate 20kHz
        .amplitude(127),
        .out(triangle_out)
    );
    
    wire [7:0] noise_envelope;
    
    AD_envelope_gen noise_ad(
    .clk(clk),
    .rst(rst_n),
    .sample_tick(sample_tick),
    .attack_time(200),
    .decay_time(5000),
    .amplitude(127),
    .note_pressed(trigger_noise),
    .envelope(noise_envelope)
    );
    
    noise_gen ng(
        .clk(clk),
        .rst(rst_n),
        .clk_div(noise_tick),
        .amplitude(noise_envelope),
        .out(noise_out)
    );
    
    
    reg [7:0] pulse1;
    reg [7:0] pulse2;
    reg [7:0] triangle;
    reg [7:0] noise;
    
    always @(posedge clk) begin
        if (sw[3])
            pulse1 <= pulse1_out;
        else
            pulse1 <= 8'd127;
            
        if (sw[2])
            pulse2 <= pulse2_out;
        else
            pulse2 <= 8'd127;
            
        if (sw[1])
            triangle <= triangle_out;
        else
            triangle <= 8'd127;
            
        if (sw[0])
            noise <= noise_out;
        else
            noise <= 8'd127;
    end
    
    mixer mx(
        .clk(clk),
        .rst(rst_n),
        .sample_tick(sample_tick),
        .in0(pulse1),
        .in1(pulse2),
        .in2(triangle),
        .in3(noise),
        .out(mixer_out)
    );
    
    PWM_gen audio_out(
        .clk(clk),
        .rst(rst_n),
        .duty(mixer_out),
        .PWM(pmod_1)
    );
    
endmodule
