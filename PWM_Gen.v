`timescale 1ns / 1ps

module PWM_gen (
    input clk,
    input rst,
    input [7:0] duty,
    output reg PWM
);

reg [7:0] count;

always @(posedge clk) begin
    if (~rst) begin
        count <= 8'd0;
        PWM <= 1'b0;
    end else begin
        count <= count + 8'd1;
        if(count < duty)
            PWM <= 1'b1;
        else
            PWM <= 1'b0;
    end
end

endmodule
