
module generateMoves(
	clock,
	reset,
	enable,
	player,
	locationVectorWhite,
	locationVectorBlack,
	aliveVectorWhite,
	aliveVectorBlack,
	moveSet
);
input clock;
input reset;
input enable;
input player;
input [95: 0]locationVectorWhite;
input [95: 0]locationVectorBlack;
input [15: 0]aliveVectorWhite;
input [15: 0]aliveVectorBlack;
output reg [112: 0]moveSet;

wire clock;
wire reset;
wire enable;

reg [31:0]pawnMoves;
reg [3:0] pawn;
reg [23:0]rookMoves;
reg [5:0]knightMoves;
reg [23:0]bishopMoves;
reg [23:0]queenMoves;
reg [2:0]kingMoves;

wire [95: 0] tempLVW, tempLVB;
wire [15: 0] tempAVW, tempAVB;

reg[5:0] board [7:0][7:0]; // Occupied, Black or White, Piece ID
	parameter BLACK = 1'b0;
	parameter WHITE = 1'b1;
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
	parameter occupied = 1'b1;
	parameter empty = 1'b0;
	
integer i, j, k, local_p;

	assign tempLVB = locationVectorBlack;
	assign tempLVW = locationVectorWhite;
	assign tempAVB = aliveVectorBlack;
	assign tempAVW = aliveVectorWhite;
	
always @(posedge clock)
	begin
	if(player) 
		local_p = 1;
	else 
		local_p = -1;
	// Board Initializing logic
	
	
	//Board Game Logic
	// White= 1; Black =0
		for(i = 0; i <= 47; i = i+6) begin
			if(local_p == 1) begin
				if(tempAVW[i/6]) begin
					if((board[tempLVW[i+: 3]+ local_p][tempLVW[i+3 +: 3]] && 6'b100000) == 6'b000000) begin
						pawn[3] <= 1'b1;
						if(((board[tempLVW[i +: 3] +(local_p * 2)][tempLVW[i+3 +: 3]] && 6'b100000) == 6'b000000 )&& (tempLVW[i +: 3] == 3'b001)) 
							pawn[2] <= 1'b1;
						else 
							pawn[2] <= 1'b0;
					end
					else 
						pawn[3:2] <= 2'b00;
					// Upper Left occupied 
					if(((board[tempLVW[i +: 3]+ local_p][tempLVW[i+3 +: 3] -1] && 6'b110_000) == 6'b100_000) ) 
						pawn[1] <= 1'b1;
					else
						pawn[1] <= 1'b0;
					if(((board[tempLVW[i +: 3]+ local_p][tempLVW[i+3 +: 3] +1] && 6'b110_000) == 6'b100_000) ) 
						pawn[0] <= 1'b1;
					else
						pawn[0] <= 1'b0;
				end 
			end
			else begin
				if(tempAVB[i/6]) begin
					if((board[tempLVB[i +: 3]+ local_p][tempLVB[i+3 +: 3]] && 6'b100000) == 6'b000000) begin
						pawn[3] <= 1'b1;
						if(((board[tempLVB[i +: 3] +(local_p * 2)][tempLVB[i+3 +: 3]] && 6'b100000) == 6'b000000 )&& (tempLVB[i +: 3] == 3'b001)) 
							pawn[2] <= 1'b1;
						else 
							pawn[2] <= 1'b0;
					end
					else 
						pawn[3:2] <= 2'b00;
					// Upper Left occupied 
					if(((board[tempLVB[i +: 3]+ local_p][tempLVB[i+3 +: 3] -1] && 6'b110_000) == 6'b110_000) ) 
						pawn[1] <= 1'b1;
					else
						pawn[1] <= 1'b0;
					if(((board[tempLVB[i +: 3]+ local_p][tempLVB[i+3 +: 3] +1] && 6'b110_000) == 6'b110_000) ) 
						pawn[0] <= 1'b1;
					else
						pawn[0] <= 1'b0;
				end 
			end
			moveSet[((i+6)*2)/3 -1 +: 4] = pawn;
			pawn <= 4'b0000;
    end
			
	end 
endmodule
