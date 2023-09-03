`timescale 1ns/1ps
module enable_control #(parameter N=8) (
    input  wire     trg,   // 
    input  wire     clkA,   // clockA
    input  wire     clkB,   // clockB
    input  wire     rst_n,   // reset_n - low to reset
    output wire     ena_A,  //enable to clk A domain
    output wire     ena_1,  //enable
    output wire     ena_2,  //enable
    output wire     ena_3  //enable
	);
    reg [2:0] count;
    reg pulseA;
    wire trgB;
    wire done;
	reg en_1, en_2, en_3;

    always @(posedge clkA or negedge rst_n or posedge done)
    begin
        if (!rst_n | done) 
            pulseA <= 'b0;
        else if (trg) 
            pulseA <= 'b1;
    end

    assign ena_A = trg;
    assign trgB = trg ^ pulseA;
	assign ena_1 = en_1;
	assign ena_2 = en_2;
	assign ena_3 = en_3;

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n | done) begin
            count <= 'b0;
		end
        else if (trgB) begin 
			count <= count + 'b1;    
        end
    end
	
	assign done = (count == 3'b100); 

    always @(count)
    case (count)
        'b000 : begin
            en_1 <= 'b0;
            en_2 <= 'b0;
            en_3 <= 'b0;
        end
        'b001 : begin
            en_1 <= 'b1;
            en_2 <= 'b1;
            en_3 <= 'b1;
        end
        'b010 : begin
            en_1 <= 'b0;
            en_2 <= 'b1;
            en_3 <= 'b1;
        end
        'b011 : begin
            en_1 <= 'b0;
            en_2 <= 'b0;
            en_3 <= 'b1;
        end
        'b100 : begin
            en_1 <= 'b0;
            en_2 <= 'b0;
            en_3 <= 'b0;
        end
		default : begin
            en_1 <= 'b0;
            en_2 <= 'b0;
            en_3 <= 'b0;
        end
    endcase

endmodule


