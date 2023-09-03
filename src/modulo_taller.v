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
    reg enable_blocks;
    wire pulse_out;

// Connect wire to reg signals 
    always @(ui_in)
    begin
        clk_2   <= ui_in[0];
        sel     <= ui_in[3:1];
        stb     <= ui_in[4];
	    pulse_in <= ui_in[5];
	    enable_blocks <= ui_in[6];
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

// Use bidirectionals as inputs
    assign uio_oe = 8'b00000000;

// input register with enable and asynchronous reset 
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            data_in <= 8'b0;
        else if (enable_blocks)
            data_in <= uio_in;
    end

// No synchronous output of datapath
    always @(posedge clk_2 or negedge rst_n)
    begin
        if(!rst_n)
            data_out_0 <= 8'b0;
        else if (enable_blocks)
            data_out_0 <= data_in;
    end

// MUX
    always @ (data_in or data_out_0 or data_out_1 or data_out_2 or data_out_3 or pulse_out or sel) begin
        case (sel)
        3'b000 : uo_out_aux  <= data_in;
        3'b001 : uo_out_aux  <= data_out_0;
        3'b010 : uo_out_aux  <= data_out_1;
        3'b011 : uo_out_aux  <= data_out_2;
	    3'b100 : uo_out_aux  <= data_out_3;
	    3'b101 : uo_out_aux  <= pulse_out;
        endcase
    end

    assign uo_out = uo_out_aux;

// Instantiate 2FF
    two_FF #(N) two_FF(
        .data_in(data_in),
        .data_out(data_out_1),
        .ena(enable_blocks),
        .clk(clk_2),
        .rst_n(rst_n)
    );

// Instantiate pulse sync
    pulse_sync #(N) pulse_sync(
        .data_in(data_in),
        .data_out(data_out_2),
        .enaA(enable_blocks),
        .enaB(enable_blocks),
        .clkA(clk),
		.clkB(clk_2),
        .stb(stb),
        .rst_n(rst_n)
    );

// Instantiate toggle sync
    tog_sync #(N) toggle_sync (
        .data_in(data_in),   // data from registered input
        .data_out(data_out_3), // data after FF's
        .pulse_out(pulse_out),      // will go high when the design is enabled
        .pulse_in(pulse_in),      // will go high when the design is enabled
        .clkA(clk),      // clock domain A
        .clkB(clk_2),      // clock domain B
        .rst_n(rst_n),     // reset_n - low to reset
        .enaA(enable_blocks),
        .enaB(enable_blocks)

    );

endmodule


