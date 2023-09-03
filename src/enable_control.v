`timescale 1ns/1ps
module enable_control #(parameter N=8) (
    input  wire     trg,   // 
    input  wire     clkA,   // clockA
    input  wire     clkB,   // clockB
    input  wire     rst_n   // reset_n - low to reset
    output wire     ena_1,  //enable to clk A domain
    output wire     ena_2,  //enable
    output wire     ena_3,  //enable
    output wire     ena_4,  //enable
    output wire     ena_5,  //enable

);
    reg [2:0] count;
    reg pulseA;
    reg trgB;
    reg done;

    always @(posedge clkA or negedge rst_n or posedge done)
    begin
        if (!rst_n or done) 
            pulseA <= 'b0;
        else if (trg) 
            pulseA <= 'b1;
    end

    assign ena_1 = trg;
    assign trgB = trg ^ pulseA;

    always @(posedge clkB or negedge rst_n)
    begin
        if (!rst_n) begin
            count <= 'b0;
            done  <= 'b0;
	end
        else if (trgB) begin 
            count <= count + 'b1;
            done  <= 'b0;
            if (count = 3'b100) begin
                count <= 3'b0;    
                done  <= 'b1;
            end
        end
    end

    always @(count)
    case (count)
        'b000 : begin
            ena_2 <= 'b0;
            ena_3 <= 'b0;
            ena_4 <= 'b0;
            ena_5 <= 'b0;
        end
        'b001 : begin
            ena_2 <= 'b1;
            ena_3 <= 'b1;
            ena_4 <= 'b1;
            ena_5 <= 'b1;
        end
        'b010 : begin
            ena_2 <= 'b0;
            ena_3 <= 'b1;
            ena_4 <= 'b1;
            ena_5 <= 'b1;
        end
        'b011 : begin
            ena_2 <= 'b0;
            ena_3 <= 'b0;
            ena_4 <= 'b1;
            ena_5 <= 'b1;
        end
        'b100 : begin
            ena_2 <= 'b0;
            ena_3 <= 'b0;
            ena_4 <= 'b0;
            ena_5 <= 'b1;
        end
		default : begin
            ena_2 <= 'b0;
            ena_3 <= 'b0;
            ena_4 <= 'b0;
            ena_5 <= 'b0;
        end
    endcase

endmodule


