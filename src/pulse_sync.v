`timescale 1ns/1ps
module pulse_sync #(parameter N=8) (
    input  wire [N-1:0] data_in,   // data from registered input
    output wire [N-1:0] data_out, // data after FF's
    input  wire       stb,      // signal to be sync
    input  wire       enaA,      // will go high when the design is enabled
    input  wire       enaB,      // will go high when the design is enabled
    input  wire       clkA,      // clock
    input  wire       clkB,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg [N-1:0] FF;
    wire [N-1:0] mux_out;

    reg ctrl, stb_in, stb_out;

    assign data_out = FF;

    // Strobe register
    always @(posedge clkA or negedge rst_n)
    begin
        if(!rst_n)
            stb_in <= 1'b0;
        else if (enaA)
            stb_in <= stb;
    end

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n) begin
            ctrl1 <= 'b0;
            ctrl2 <= 'b0;
        end
        else if (enaB) begin
            ctrl1 <= stb;
            ctrl2 <= ctrl1;
        end
    end

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n)
            FF <= 'b0;
        else if (enaB)
            FF <= mux_out;
    end
endmodule


