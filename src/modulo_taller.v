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


// Connect wire to reg signals 
     always @(ui_in)
    begin
        clk_2 <= ui_in[0];
        sel   <= ui_in[3:1];
    end

// Strobe register
     always @(posedge clk or negedge rst_n)
    begin
            if(!rst_n)
                    stb <= 1'b0;
            else if (ena)
                    stb <= ui_in[4];
    end
    // Connects to ground inputs 7 to 5 of ui_in
    assign uio_out[7:0] = 8'b00000000;

// More regs
    reg [(N-1):0] data_in; // Output from register of data in
    reg [(N-1):0] data_out_0; // Metaestable output, no synch
    wire [(N-1):0] data_out_1;
    wire [(N-1):0] data_out_2;
    reg [(N-1):0] uo_out_aux;
// use bidirectionals as inputs
    assign uio_oe = 8'b00000000;

// input register with enable and asynchronous reset 
    always @(posedge clk or negedge rst_n)
    begin
            if(!rst_n)
                    data_in <= 8'b0;
            else if (ena)
                    data_in <= uio_in;
    end

// No synchronous output of datapath
    always @(posedge clk_2 or negedge rst_n)
    begin
            if(!rst_n)
                    data_out_0 <= 8'b0;
            else if (ena)
                    data_out_0 <= data_in;
    end


// MUX
    always @ (data_out_0 or data_in or data_out_1 or data_out_2 or sel) begin
        case (sel)
        3'b000 : uo_out_aux  <= data_in;
        3'b001 : uo_out_aux  <= data_out_0;
        3'b010 : uo_out_aux  <= data_out_1;
        3'b011 : uo_out_aux  <= data_out_2;
        endcase
    end

    assign uo_out = uo_out_aux;
        
// Instantiate 2FF
    two_FF two_FF(.data_in(data_in),.data_out(data_out_1),.ena(ena),.clk(clk_2),.rst_n(rst_n));
// Instantiate pulse sync
    pulse_sync pulse_sync(.data_in(data_in),.data_out(data_out_2),.ena(ena),.clk(clk_2),.stb(stb),.rst_n(rst_n));

endmodule


