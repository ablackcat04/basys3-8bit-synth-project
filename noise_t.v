`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 22:39:57
// Design Name: 
// Module Name: noise_t
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module noise_t(

    );
    
    
    reg rst;
    
    reg clk;
    wire clk_div;
    reg [6:0] amplitude;
    wire [7:0] out;

    parameter cyc = 10;
    always #cyc clk <= ~clk;

    
    clock_divider cd(clk, rst, 32'd8, clk_div);
    
    noise n(
        clk,
        rst,
        clk_div,
        amplitude,
        out
    );
    
    initial begin
        clk <= 1'b1;
        rst <= 1'b1;
        amplitude <= 8'd127;
        
        #10 rst <= 1'b0;
        #20 rst <= 1'b1;
        
        #500;
        amplitude <= 8'd10;
        
        #1000;
        
        
    end
    
    
endmodule
