`timescale 1ns/1ps
module two_FF_tb #(parameter N=8);
    logic clkA;
    logic clkB;
    logic pulse_in;
    logic pulse_out;
    logic rstn;
    logic [N-1:0] data_in, data_out;
    
    always #5 clkA = ~clkA;
    always #10 clkB = ~clkB;

    tog_sync #(N) dut (    .data_in 	(data_in),
                    .data_out	(data_out),
                  	.clkA 		(clkA),
                  	.clkB 	    (clkB),
                  	.pulse_in  (pulse_in),
                  	.pulse_out  (pulse_out),
                  	.rst_n 		(rstn));

  initial begin
    bit [N-1:0] d_in; 
    // Initialize testbench variables
    clkA <= 0;
    clkB <= 0;
    rstn <= 0;
    pulse_in <=0;
    data_in <= 0;
  end

  initial begin
    rstn = 0;
    pulse_in = 0;
    wait_tA(2);
    rstn = 1;
    data_in <= 'hAA;
    wait_tA(4);
    pulse_in = 1;
    wait_tA(1);
    pulse_in = 0;
    wait_tA(10);
    data_in <= 'hFF;
    wait_tA(4);
    pulse_in = 1;
    wait_tA(1);
    pulse_in = 0;
    wait_tA(10);
    $finish;

  end

  task wait_tA (input integer index);
	//Index is the clock cycles to wait
   integer	j; //for counting variable
        for (j=1; j<=index; j=j+1) //
            @(posedge clkA);
  endtask	

  task wait_tB (input integer index);
	//Index is the clock cycles to wait
   integer	j; //for counting variable
        for (j=1; j<=index; j=j+1) //
            @(posedge clkB);
  endtask

endmodule
