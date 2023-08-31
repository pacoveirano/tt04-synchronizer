`timescale 1ns/1ps
module two_FF_tb #(parameter N=8);
    logic clk;
    logic ena, rstn;
    logic [N-1:0] data_in, data_out;
    
    always #5 clk = ~clk;

    two_FF #(N) s0 (    .data_in 	(data_in),
                    .data_out	(data_out),
                  	.ena 		(ena),
                  	.clk 	    (clk),
                  	.rst_n 		(rstn));

  initial begin
    bit enable;
    bit [N-1:0] d_in;
    
    // Initialize testbench variables
    clk <= 0;
    ena <= 0;
    rstn <= 1;
    data_in <= 0;
  end

  initial begin
    rstn = 0;
    wait_t(2);
    rstn = 1;
    data_in <= 'hAA;
    wait_t(4);
    ena = 1;
    wait_t(5);
    data_in <= 'hFF;
    wait_t(5);
  $finish;
  end

  task wait_t (input integer index);
	//Index is the clock cycles to wait
   integer	j; //for counting variable
        for (j=1; j<=index; j=j+1) //
            @(posedge clk);

endtask	

endmodule
