`default_nettype none
`timescale 1ns/1ps

// testbench
module tb ();

    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs
    reg  clk;
    reg  rst_n;
    reg  ena;
    reg  clk_2;
    reg  stb;
    reg  [2:0] sel;
    reg  [7:0] uio_in;
    reg  [7:0] ui_in;
    reg  ena_blk;
	 reg  pulse_in;
	 reg  trg;    

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    integer	j;
    // Clocks
 //   always #18 clk = ~clk;
 //   always #7 clk_2 = ~clk_2;

    assign ui_in[0] = clk_2;
    assign ui_in[1] = sel[0];
    assign ui_in[2] = sel[1];
    assign ui_in[3] = sel[2];
    assign ui_in[4] = stb;
    assign ui_in[5] = pulse_in;
	 assign ui_in[6] = ena_blk;
	 assign ui_in[7] = trg;
    
    tt_um_fing_synchronizer_hga tt_um_fing_synchronizer_hga(
        .ui_in      (ui_in),    // Dedicated inputs
        .uo_out     (uo_out),   // Dedicated outputs
        .uio_in     (uio_in),   // IOs: Input path
        .uio_out    (uio_out),  // IOs: Output path
        .uio_oe     (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena        (ena),      // enable - goes high when design is selected
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
        );


endmodule
