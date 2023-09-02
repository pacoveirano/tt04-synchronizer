`timescale 1ns/1ps
module tog_sync #(parameter N=8) (
    input  wire [N-1:0] data_in,   // data from registered input
    output wire [N-1:0] data_out, // data after FF's
    output wire     pulse_out,      // will go high when the design is enabled
    input  wire     pulse_in,      // will go high when the design is enabled
    input  wire     clkA,       // clock domain A
    input  wire     clkB,       // clock domain B
    input  wire     rst_n,      // reset_n - low to reset
    input  wire     ena         // enable - high
    );

    reg [N-1:0] DATA_A;
    reg [N-1:0] DATA_B;

    reg A, B1, B2, B3;

    always @(posedge clkA or negedge rst_n)
    begin
        if (!rst_n) begin
            A <= 'b0;
        end
        else begin
            if (pulse_in & ena) 
		        A <= ~A;
        end
    end

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n) begin
            B1 <= 'b0;
            B2 <= 'b0;
            B3 <= 'b0;
	    end 
        else begin
            if (ena)
                B1 <= A;
                B2 <= B1;
                B3 <= B2;		
	    end
    end

    assign pulse_out = (B2 ^ B3);

    always @(posedge clkA or negedge rst_n)
    begin
        if (!rst_n) 
            DATA_A <= 'b0;
        else
            if (ena)
	            DATA_A <= data_in;
    end

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n) begin
            DATA_B <= 'b0;
	    end 
        else begin
	        if (pulse_out & ena)
	    	    DATA_B <= DATA_A;	
	    end
    end

    assign data_out = DATA_B;

endmodule


