module check_fn (done, clk, RST, en, player, location_vectors_w, location_vectors_b, alive_vectors_w, alive_vectors_b, is_check);
	input clk;
	input RST;
	input player;
	input en;
	input [95:0] location_vectors_w;
	input [95:0] location_vectors_b;
	input [15:0] alive_vectors_w;
	input [15:0] alive_vectors_b;
	output [15:0] is_check;
	output done;
	
	reg en_q;
	reg en_d;
	reg [15:0] is_check_d;
	reg [15:0] is_check_q;
	reg[5:0] board [7:0][7:0];
	reg state_d;
	reg state_q;
	reg done_d;
	reg done_q;
	reg[95:0] BLACK    = 96'b101111_101110_101101_101100_101011_101010_101001_101000_100111_100110_100101_100100_100011_100010_100001_100000;
   reg[95:0] WHITE    = 96'b111111_111110_111101_111100_111011_111010_111001_111000_110111_110110_110101_110100_110011_110010_110001_110000;

	parameter WAIT = 1'b0;
	parameter GO = 1'b1;
	
	parameter BLACK_BIT = 1'b0;
	parameter WHITE_BIT = 1'b1;
	parameter P1 = 4'b1111;
	parameter P2 = 4'b1110;
	parameter P3 = 4'b1101;
	parameter P4 = 4'b1100;
	parameter P5 = 4'b1011;
	parameter P6 = 4'b1010;
	parameter P7 = 4'b1001;
	parameter P8 = 4'b1000;
	parameter R1 = 4'b0111;
	parameter R2 = 4'b0110;
	parameter N1 = 4'b0101;
	parameter N2 = 4'b0100;
	parameter B1 = 4'b0011;
	parameter B2 = 4'b0010;
	parameter Q1 = 4'b0001;
	parameter K1 = 4'b0000;
	//parameter INITIALIZE_LOCATIONS_WHITE = 96'h20928B30D38F0070460850C4; //P1P2P3P4P5P6P7P8R1R2N1N2B1B2Q1K1
	//parameter INITIALIZE_LOCATIONS_BLACK = 96'hC31CB3D35DB7E3FE7EEBDEFC; //P1P2P3P4P5P6P7P8R1R2N1N2B1B2Q1K1
	
	wire [95: 0] tempLVW, tempLVB;
   wire [15: 0] tempAVW, tempAVB;
	
	assign is_check = is_check_q;
   assign tempLVB = location_vectors_b;
   assign tempLVW = location_vectors_w;
   assign tempAVB = alive_vectors_b;
   assign tempAVW = alive_vectors_w;
	
	integer i, j, check_left=1, check_right=1, check_down=1, check_up=1;
	integer go_left=1, go_right=1, go_up=1, go_down=1;
	
	
	always @(*) begin
		is_check_d = is_check_q;
		en_d = en_q;
		case (state_q)
			WAIT : begin
				if (en_q) begin
					for(i = 7; i >= 0; i = i-1) begin
						for(j = 7; j >= 0; j = j-1) begin
							board[i][j] = 6'b000000;
						end
						for(i = 95; i > 0; i = i-6) begin
							if (tempAVW[i/6]) begin
								board[tempLVW[i -: 3]][tempLVW[(i-3) -: 3]] = WHITE[i -:6];
							end
							if (tempAVB[i/6]) begin
								board[tempLVB[i -: 3]][tempLVB[(i-3) -: 3]] = BLACK[i -: 6];
							end
						end
					end
					state_d = GO;
				end
				else begin
					state_d = WAIT;
					check_left=1;
					check_right=1;
					check_down=1;
					check_up=1;
					go_left=1;
					go_right=1;
					go_down=1;
					go_up=1;
				end
			end
			GO : begin
				if (player == BLACK_BIT) begin
					//initially check king position to see what to directions to check
					if (tempLVB[5:3] == 3'b111) begin //if its on the very top, no need to check up
						check_up = 0;
						if(tempLVB[2:0] == 3'b000) //if its on the very left, no need to check left
							check_left=0;
						else if (tempLVB[2:0] == 3'b111) //if its on the veryy right, no need to check right
							check_right=0;
					end
					else if(tempLVB[5:3] == 0) begin //if its on the very bottom, no need to check down
						if(tempLVB[2:0] == 3'b000) //if its on the very left, no need to check left
							check_left=0;
						else if (tempLVB[2:0] == 3'b111) //if its on the veryy right, no need to check right
							check_right=0;	
					end
					else if(tempLVB[2:0] == 3'b000) begin //if its on the very left, no need to check left
						check_left = 0;
						if(tempLVB[5:3] == 3'b000) //if at the bottom, no need to check bottom
							check_down = 0;
						else if (tempLVB[5:3] == 3'b111) 
							check_up = 0;
					end
					else if(tempLVB[2:0] == 3'b111) begin //if its on the very right, no need to check right
						check_right = 0;
						if(tempLVB[5:3] == 3'b000) //if at the bottom, no need to check bottom
							check_down = 0;
						else if (tempLVB[5:3] == 3'b111) 
							check_up = 0;
					end
					//end initially checking king position
					
					for(i = 1; i <= 7; i = i+1) begin
							if (check_down==0) begin	
								if (check_right==0) begin
//								// LEFT SITUATION --------------------------------------------------------------------------------------
									if ((tempLVW[5:3] - i > 0) && go_left == 1) begin
										if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b110_000) == 6'b100_000)) //if black piece exists, it is protected
											go_left=0;
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_000) == 6'b111_000) || ((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_110) == 6'b110_100) || ((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_110) == 6'b110_010) || ((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_000)) 
											//if white pawn or knight or bishop or king
											go_left=0;
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_111)) begin
											//if white occupied and R1.. in check
											go_left=0;
											is_check_d[R1]= 1'b1;
										end
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_110)) begin
											//if white occupied and R2.. in check
											go_left=0;
											is_check_d[R2]= 1'b1;
										end
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_001)) begin
											//if white occupied and Q.. in check
											go_left=0;
											is_check_d[Q1]= 1'b1;
										end	
									end
									
									else if((tempLVW[5:3] - i == 0) && go_left == 1) begin
										if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b110_000) == 6'b100_000)) //if black piece exists, it is protected
											go_left=0;
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_111)) begin
											//if white occupied and R1.. in check
											go_left=0;
											is_check_d[R1]= 1'b1;
										end
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_110)) begin
											//if white occupied and R2.. in check
											go_left=0;
											is_check_d[R2]= 1'b1;
										end
										else if(((board[tempLVB[5:3]-i][tempLVB[2:0]] & 6'b111_111) == 6'b110_001)) begin
											//if white occupied and Q.. in check
											go_left=0;
											is_check_d[Q1]= 1'b1;
										end	
										go_left=0;
									end
								// END LEFT SITUATION ---------------------------------------------------------------------------------------------
								// UP SITUATION ---------------------------------------------------------------------------------------------------
									
								// END UP SITUATION -----------------------------------------------------------------------------------------------
								// UP_LEFT SITUATION ----------------------------------------------------------------------------------------------
									
								// END UP_LEFT SITUATION ------------------------------------------------------------------------------------------
								end
								
								else if(check_left==0) begin
								
								end
								else begin
								
								end
							end
							
							else if (check_up==0) begin
								if (check_right==0) begin
									
								end
								else if(check_left==0) begin
								
								end
								else begin
								
								end
							end
							else if (check_right==0) begin //right not possible
								if (check_up==0) begin
									
								end
								else if(check_down==0) begin
								
								end
								else begin
								
								end
							end
							else if (check_left==0) begin //left not possible
								if (check_up==0) begin
									
								end
								else if(check_down==0) begin
								
								end
								else begin
								
								end
							end
							else begin //every direction possible
							
							end
					end
					state_d = WAIT;
				end
				else if (player == WHITE_BIT) begin
					state_d = WAIT;
				end
			end
		endcase
	end
	
	always @(posedge clk) begin
		if (RST) begin
			state_q <= WAIT;
			en_q <= 0;
			is_check_q <= 16'b0000_0000_0000_0000;
		end
		else begin
			state_q <= state_d;
			is_check_q <= is_check_d;
			en_q <= en;
			done_q <= done_d;		
		end
	end
	
endmodule
