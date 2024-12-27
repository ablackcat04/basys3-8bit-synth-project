`timescale 1ns / 1ps

module clock_divider(
    input clk,
    input rst_n,
    input [31:0] num,
    output reg clk_div
    );
    
    reg [31:0] count;
    
    wire enough;
    assign enough = count >= num - 32'd1;
    
    always @(posedge clk) begin
        if (~rst_n || !enough) begin
            clk_div <= 1'b0;
        end else begin            
            clk_div <= 1'b1;
        end
        
        if (~rst_n || enough) begin
            count <= 32'd0;
        end else begin            
            count <= count + 32'd1;
        end
    end
        
endmodule
