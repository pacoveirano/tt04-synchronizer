`timescale 1ns/1ps
module two_FF #(parameter N=8) (
    input  wire [N-1:0] data_in,   // data from registered input
    output reg [N-1:0] data_out, // data after FF's
    output reg [N-1:0] FF1,               // Output of the first FlipFlor
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin
            FF1 <= 'b0;
            data_out <= 'b0;
	end
        else if (ena) begin 
            FF1 <= data_in;
            data_out <= FF1;
        end
    end

endmodule


