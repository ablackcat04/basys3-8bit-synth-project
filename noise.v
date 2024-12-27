`timescale 1ns / 1ps

module noise_gen(
    input clk,
    input rst,
    input clk_div,
    input [6:0] amplitude,
    output [7:0] out
    );
    
    reg [7:0] noise;
    
    always @(posedge clk) begin
        if (~rst) begin
            noise <= 8'd27;
        end else begin
            if (clk_div) begin
                noise[7] <= noise[6];
                noise[6] <= noise[5];
                noise[5] <= noise[4];
                noise[4] <= noise[3];
                noise[3] <= noise[2];
                noise[2] <= noise[1];
                noise[1] <= noise[0];
                noise[0] <= noise[3] ^ noise[7];
            end else begin
                noise <= noise;
            end
        end
    end
    
    assign out = ((noise * amplitude) / 16'd127) + 8'd127 - amplitude;
    
endmodule
