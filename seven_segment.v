//Author: K. Pandya

module seven_segment(
	clk50, 
	code, 
	seg0, 
	seg1,
	seg2,
	seg3
	);
	
	parameter[6:0] SEG_0 = 7'b1000000;
	parameter[6:0] SEG_1 = 7'b1111001;
	parameter[6:0] SEG_2 = 7'b0100100;
	parameter[6:0] SEG_3 = 7'b0110000;
	parameter[6:0] SEG_4 = 7'b0011001;
	parameter[6:0] SEG_5 = 7'b0010010;
	parameter[6:0] SEG_6 = 7'b0000010;
	parameter[6:0] SEG_7 = 7'b1111000;
	parameter[6:0] SEG_8 = 7'b0000000;
	parameter[6:0] SEG_9 = 7'b0010000;
	parameter[6:0] SEG_A = 7'b0001000;
	parameter[6:0] SEG_B = 7'b0000011;
	parameter[6:0] SEG_C = 7'b1000110;
	parameter[6:0] SEG_D = 7'b0100001;
	parameter[6:0] SEG_E = 7'b0000110;
	parameter[6:0] SEG_F = 7'b0001110;
	
	input clk50;
	input[15:0] code;
	output reg[6:0] seg0, seg1, seg2, seg3;
	
	always @(posedge clk50) begin

		case(code[15:12])
			4'h0:
				begin
					seg3 <= SEG_0;
				end
			4'h1:
				begin
					seg3 <= SEG_1;
				end
			4'h2:
				begin
					seg3 <= SEG_2;
				end
			4'h3:
				begin
					seg3 <= SEG_3;
				end
			4'h4:
				begin
					seg3 <= SEG_4;
				end
			4'h5:
				begin
					seg3 <= SEG_5;
				end
			4'h6:
				begin
					seg3 <= SEG_6;
				end
			4'h7:
				begin
					seg3 <= SEG_7;
				end
			4'h8:
				begin
					seg3 <= SEG_8;
				end
			4'h9:
				begin
					seg3 <= SEG_9;
				end
			4'hA:
				begin
					seg3 <= SEG_A;
				end
			4'hB:
				begin
					seg3 <= SEG_B;
				end
			4'hC:
				begin
					seg3 <= SEG_C;
				end
			4'hD:
				begin
					seg3 <= SEG_D;
				end
			4'hE:
				begin
					seg3 <= SEG_E;
				end
			4'hF:
				begin
					seg3 <= SEG_F;
				end
		endcase
		
		case(code[11:8])
			4'h0:
				begin
					seg2 <= SEG_0;
				end
			4'h1:
				begin
					seg2 <= SEG_1;
				end
			4'h2:
				begin
					seg2 <= SEG_2;
				end
			4'h3:
				begin
					seg2 <= SEG_3;
				end
			4'h4:
				begin
					seg2 <= SEG_4;
				end
			4'h5:
				begin
					seg2 <= SEG_5;
				end
			4'h6:
				begin
					seg2 <= SEG_6;
				end
			4'h7:
				begin
					seg2 <= SEG_7;
				end
			4'h8:
				begin
					seg2 <= SEG_8;
				end
			4'h9:
				begin
					seg2 <= SEG_9;
				end
			4'hA:
				begin
					seg2 <= SEG_A;
				end
			4'hB:
				begin
					seg2 <= SEG_B;
				end
			4'hC:
				begin
					seg2 <= SEG_C;
				end
			4'hD:
				begin
					seg2 <= SEG_D;
				end
			4'hE:
				begin
					seg2 <= SEG_E;
				end
			4'hF:
				begin
					seg2 <= SEG_F;
				end
		endcase
		
		case(code[7:4])
			4'h0:
				begin
					seg1 <= SEG_0;
				end
			4'h1:
				begin
					seg1 <= SEG_1;
				end
			4'h2:
				begin
					seg1 <= SEG_2;
				end
			4'h3:
				begin
					seg1 <= SEG_3;
				end
			4'h4:
				begin
					seg1 <= SEG_4;
				end
			4'h5:
				begin
					seg1 <= SEG_5;
				end
			4'h6:
				begin
					seg1 <= SEG_6;
				end
			4'h7:
				begin
					seg1 <= SEG_7;
				end
			4'h8:
				begin
					seg1 <= SEG_8;
				end
			4'h9:
				begin
					seg1 <= SEG_9;
				end
			4'hA:
				begin
					seg1 <= SEG_A;
				end
			4'hB:
				begin
					seg1 <= SEG_B;
				end
			4'hC:
				begin
					seg1 <= SEG_C;
				end
			4'hD:
				begin
					seg1 <= SEG_D;
				end
			4'hE:
				begin
					seg1 <= SEG_E;
				end
			4'hF:
				begin
					seg1 <= SEG_F;
				end
		endcase
		
		case(code[3:0])
			4'h0:
				begin
					seg0 <= SEG_0;
				end
			4'h1:
				begin
					seg0 <= SEG_1;
				end
			4'h2:
				begin
					seg0 <= SEG_2;
				end
			4'h3:
				begin
					seg0 <= SEG_3;
				end
			4'h4:
				begin
					seg0 <= SEG_4;
				end
			4'h5:
				begin
					seg0 <= SEG_5;
				end
			4'h6:
				begin
					seg0 <= SEG_6;
				end
			4'h7:
				begin
					seg0 <= SEG_7;
				end
			4'h8:
				begin
					seg0 <= SEG_8;
				end
			4'h9:
				begin
					seg0 <= SEG_9;
				end
			4'hA:
				begin
					seg0 <= SEG_A;
				end
			4'hB:
				begin
					seg0 <= SEG_B;
				end
			4'hC:
				begin
					seg0 <= SEG_C;
				end
			4'hD:
				begin
					seg0 <= SEG_D;
				end
			4'hE:
				begin
					seg0 <= SEG_E;
				end
			4'hF:
				begin
					seg0 <= SEG_F;
				end
		endcase
	end
endmodule
