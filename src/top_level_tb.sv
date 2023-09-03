`default_nettype none
`timescale 1ns/1ps

// testbench
module tb ();

    // wire up the inputs
    reg  clk;
    reg  rst_n;
    reg  ena;
	reg  ena_blk;
	reg  pulse_in;
    reg  clk_2;
    reg  stb;
	reg  trg;
    reg  [2:0] sel;
    reg  [7:0] uio_in;
    reg  [7:0] ui_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    integer	j;

    // Clocks
    always #5 clk = ~clk;
    always #10 clk_2 = ~clk_2;

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

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        clk <= 0;
        clk_2 <= 0;
        rst_n  <= 0;
        ena    <= 0;
		ena_blk <= 0;
		pulse_in <= 0;
        uio_in <= 0;
        stb <= 0;
        sel <= '0;
        trg <= '0;
    end

    initial begin
        #20
    //Simulación con SEL=0 únicamente registramos la entrada
        rst_n <= 1;
        ena   <= 1;
		ena_blk <= 1;
        sel   <= 0;
        #3 uio_in <= 01010101;
        #30;
    //Simulación con SEL=1, registramos con reloj 2 sin sicnronizar
        sel <= 1;
        #3 uio_in <= 11111111;
        #40
    //Simulación con SEL=2, registramos con sincro de dos FF en cascada
        sel <= 2;
        #3 uio_in <= 00000000;
        #50
    //Simulación con SEL=3, registramos con sincro con señal de control
        sel <= 3;
        #3 uio_in <= 'hFF;
        #5 stb <= 1;
        #40 stb <= 0;
    	#50
    //Simulación con SEL=4, registramos con sincro con señal de control
        sel <= 4;
        #3 uio_in <= 'hAB;
        #7 pulse_in <= 1;
        #40 pulse_in  <= 0;
		#50
    //Simulación con SEL=5, registramos con sincro con señal de control
        sel <= 5;
        #3 uio_in <= 'hDA;
        #5 pulse_in <= 1;
        #40 pulse_in  <= 0;
        #50;
    
        #20
    //Simulación con SEL=0 únicamente registramos la entrada
        rst_n <= 1;
        ena   <= 1;
        ena_blk <= 0;
        sel   <= 1;
        pulse_in <= 1;
		stb <= 1;
		uio_in <= 'hAB;
        trg <= '1;
		#10 trg <= '0;
        pulse_in <= 0;
		stb <= 0;
		uio_in <= 'h00;
        #450;
    $finish;
    end


endmodule
