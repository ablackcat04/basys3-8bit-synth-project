`timescale 1ns / 1ps

module clock_divider_t(
    
    );
    
    parameter cyc = 10;
    
    reg clk;
    reg rst;
    reg [31:0] num;
    wire clk_div;
    
    clock_divider cd(
    clk,
    rst,
    num,
    clk_div
    );
    
    always #cyc clk <= ~clk;
    
    initial begin
        clk <= 1'b0;
        num <= 32'd5;
        rst <= 1'b1;
        
        #10 rst <= 1'b0;
        #10 rst <= 1'b0;
        #10 rst <= 1'b1;
        
        #2000;
    end
    
endmodule
