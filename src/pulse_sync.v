`timescale 1ns/1ps
module pulse_sync #(parameter N=8) (
    input  wire [N-1:0] data_in,   // data from registered input
    output reg [N-1:0] data_out, // data after FF's
    input  wire       stb,      // will go high when the design is enabled
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg [N-1:0] FF;
    wire [N-1:0] mux_out;

    reg ctrl1, ctrl2;

    assign data_out = FF;

    // MUX 
    assign mux_out = ctrl2 ? data_in : FF;

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin
            ctrl1 <= 'b0;
            ctrl2 <= 'b0;
        end
        else if (ena) begin
            ctrl1 <= stb;
            ctrl2 <= ctrl1;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            FF <= 'b0;
        else if (ena)
            FF <= mux_out;
    end
endmodule


