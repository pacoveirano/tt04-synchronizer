`timescale 1ns/1ps
module pulse_sync #(parameter N=8) (
    input  wire [N-1:0] data_in,    // data from registered input
    output wire [N-1:0] data_out,   // data after FF's
    input  wire       stb,          // signal to be sync
    output wire       stb_out,      // signal to be sync
    input  wire       enaA,      // will go high when the design is enabled
    input  wire       enaB,      // will go high when the design is enabled
    input  wire       clkA,      // clock
    input  wire       clkB,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg [N-1:0] FF;
    reg ctrl, stb_in, stb_o;

    assign data_out = FF;
    assign stb_out = stb_o;
    
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
            ctrl 	<= 'b0;
            stb_o <= 'b0;
        end
        else if (enaB) begin
            ctrl <= stb_in;
            stb_o <= ctrl;
        end
    end

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n)
            FF <= 'b0;
        else if (enaB & stb_o)
            FF <= data_in;
    end
endmodule


