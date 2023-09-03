`timescale 1ns/1ps
module tt_um_fing_synchronizer_hga #( parameter N = 8) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

// Inputs auxiliary clock, select, and strobe 
    reg clk_2;
    reg [2:0] sel;
    reg stb; 
    reg pulse_in;
    reg trigger;
    reg enable_blocks;

// Auxiliar signals
    wire ena_A, ena_1, ena_2, ena_3, done;	//From enable_control
	wire A, B1, B2, B3, pulse_out;		//From toggle
	wire stb_in, ctrl, stb_out;			//From pulse

// Connect wire to reg signals 
    always @(ui_in)
    begin
        clk_2   <= ui_in[0];
        sel     <= ui_in[3:1];
        stb     <= ui_in[4];
	    pulse_in <= ui_in[5];
	    enable_blocks <= ui_in[6];
        trigger <= ui_in[7];
    end

// Connects to ground inputs 7 to 5 of ui_in
    assign uio_out[7:0] = 8'b00000000;

// More regs
    reg [(N-1):0] data_in; // Output from register of data in
    reg [(N-1):0] data_out_0; // Metaestable output, no synch
    wire [(N-1):0] data_out_1;
    wire [(N-1):0] data_out_2;
    wire [(N-1):0] data_out_3;
    reg [(N-1):0] uo_out_aux;
	wire [(N-1):0] FF1;

// Use bidirectionals as inputs
    assign uio_oe = 8'b00000000;

// input register with enable and asynchronous reset 
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            data_in <= 8'b0;
        else if (enable_blocks | ena_A)
            data_in <= uio_in;
    end

// No synchronous output of datapath
    always @(posedge clk_2 or negedge rst_n)
    begin
        if(!rst_n)
            data_out_0 <= 8'b0;
        else if (enable_blocks | ena_1)
            data_out_0 <= data_in;
    end

// MUX
    always @ (sel or data_in or data_out_0 or data_out_1 or data_out_2 or data_out_3 or 
			stb_in or ctrl or stb_out or A or B1 or B2 or B3 or pulse_out or
			ena_A or ena_1 or ena_2 or ena_3 or FF1) begin
        case (sel)
        3'b000 : uo_out_aux  <= data_in;
        3'b001 : uo_out_aux  <= data_out_0;
        3'b010 : uo_out_aux  <= data_out_1;
        3'b011 : uo_out_aux  <= data_out_2;
	    3'b100 : uo_out_aux  <= data_out_3;
		3'b101 : uo_out_aux  <= {stb_in, ctrl, stb_out, A, B1, B2, B3, pulse_out};
		3'b110 : uo_out_aux  <= {{(N-5){1'b0}}, ena_A, ena_1, ena_2, ena_3, done};
		3'b111 : uo_out_aux  <= FF1;
		default : uo_out_aux <= 'b0;
        endcase
    end

    assign uo_out = uo_out_aux;

// Instantiate 2FF
    two_FF #(N) two_FF(
        .data_in(data_in),
        .data_out(data_out_1),
        .ena(enable_blocks | ena_2),
        .clk(clk_2),
		.FF1(FF1),
        .rst_n(rst_n)
    );

// Instantiate pulse sync
    pulse_sync #(N) pulse_sync(
        .data_in(data_in),
        .data_out(data_out_2),
        .enaA(enable_blocks | ena_A),
        .enaB(enable_blocks | ena_3),
        .clkA(clk),
		.clkB(clk_2),
        .stb(stb),
        .stb_out(stb_out),
        .rst_n(rst_n),
		.ctrl(ctrl),
		.stb_in(stb_in)
    );

// Instantiate toggle sync
    tog_sync #(N) tog_sync (
        .data_in(data_in),   // data from registered input
        .data_out(data_out_3), // data after FF's
        .pulse_out(pulse_out),      // will go high when the design is enabled
        .pulse_in(pulse_in),      // will go high when the design is enabled
        .clkA(clk),      // clock domain A
        .clkB(clk_2),      // clock domain B
        .rst_n(rst_n),     // reset_n - low to reset
        .enaA(enable_blocks | ena_A),
        .enaB(enable_blocks | ena_3),
		.A(A),
		.B1(B1),
		.B2(B2),
		.B3(B3)
    );	

    enable_control ec (
        .trg(trigger),   // Pulse from clkA
        .clkA(clk),   // clockA
        .clkB(clk_2),   // clockB
        .rst_n(rst_n),   // reset_n - low to reset
        .ena_A(ena_A),  //enable to clk A domain
        .ena_1(ena_1),  //enable
        .ena_2(ena_2),  //enable
        .ena_3(ena_3),  //enable
		.done(done)
    );

endmodule


