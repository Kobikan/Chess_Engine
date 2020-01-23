
module generateMoves(
	clock,
	reset,
	enable,
	player,
	pieceLocation,
	piece,
	pawnMoves,
	rookMoves,
	knightMoves,
	bishopMoves,
	queenMoves,
	kingMoves
);
input clock;
input reset;
input enable;
input player;
input pieceLocation;

output piece;
output pawnMoves;
output rookMoves;
output knightMoves;
output bishopMoves;
output queenMoves;
output kingMoves;

wire clock;
wire reset;
wire enable;
reg [11:0]pawnMoves;
reg [11:0]rookMoves;
reg [11:0]knightMoves;
reg [11:0]bishopMoves;
reg [23:0]queenMoves;
reg [11:0]kingMoves;

reg[3:0] board [7:0][7:0];

integer i, j, k;

localparam PIECE_NONE 	= 4'b0000;

// White
localparam PIECE_PAWN	= 4'b0001;
localparam PIECE_ROOK	= 4'b0010;
localparam PIECE_KNIGHT	= 4'b0011;
localparam PIECE_BISHOP	= 4'b0100;
localparam PIECE_QUEEN	= 4'b0101;
localparam PIECE_KING	= 4'b0110;

//Black
localparam BPIECE_PAWN	= 4'b1001;
localparam BPIECE_ROOK	= 4'b1010;
localparam BPIECE_KNIGHT= 4'b1011;
localparam BPIECE_BISHOP= 4'b1100;
localparam BPIECE_QUEEN	= 4'b1101;
localparam BPIECE_KING	= 4'b1110;

  check pawnGet(
    .piece   (PIECE_PAWN)
	 .moveSet (pawnMoves)
	 
  );
    check rookGet(
    .piece   (PIECE_ROOK)
	 .moveSet (rookMoves)

  );
    check knightGet(
    .piece   (PIECE_KNIGHT)
	 .moveSet (knightMoves)

  );
    check bishopGet(
    .piece   (PIECE_BISHOP)
	 .moveSet (bishopMoves)

  );
    check kingGet(
    .piece   (PIECE_KING)
	 .moveSet (kingMoves)

  );


always @(posedge clock)
	begin
	// Board Initializing logic
		for(i=0; i< 8; i = i+ 1) begin
			for(j=0; j< 8; j = j+ 1) begin
				if(reset == 1) begin
					if(i == 1) begin
						board[i][j] <= PIECE_PAWN;
						
					end else if(i == 6) begin
						board[i][j] <= BPIECE_PAWN;
						
					end else if(i == 0) begin
					
						if(j == 0 || j == 7)begin 
							board[i][j] <= PIECE_ROOK;
						end else if(j == 1 || j == 6) begin
							board[i][j] <= PIECE_KNIGHT;
						end else if(j == 2 || j == 5) begin
							board[i][j] <= PIECE_BISHOP;
						end else if(j == 3) begin
							board[i][j] <= PIECE_QUEEN;
						end else if(j == 4) begin
							board[i][j] <= PIECE_KING;
						end
						
					end else if(i == 7) begin
						if(j == 0 || j == 7)begin 
							board[i][j] <= BPIECE_ROOK;
						end else if(j == 1 || j == 6) begin
							board[i][j] <= BPIECE_KNIGHT;
						end else if(j == 2 || j == 5) begin
							board[i][j] <= BPIECE_BISHOP;
						end else if(j == 3) begin
							board[i][j] <= BPIECE_QUEEN;
						end else if(j == 4) begin
							board[i][j] <= BPIECE_KING;
						end
						
					end 
				end else begin
					// Add Logic Depending on how values are sent in
				end
			end
		end
	
	// Find all possible pieces move possibilities
		
		
	// Generate possible moves
	for(i=0; i< 8; i = i+ 1) begin
		for(j=0; j< 8; j = j+ 1) begin
			if(board[i][j] != PIECE_NONE) begin
				if(board[i][j][3] == player) begin
					if(board[i][j] == PIECE_PAWN)begin
						if (player == 0)begin 
							
						end else begin
						end
					end else if(board[i][j] == PIECE_ROOK) begin
					end else if(board[i][j] == PIECE_KNIGHT) begin
					end else if(board[i][j] == PIECE_BISHOP) begin
					end else if(board[i][j] == PIECE_QUEEN) begin
					end else if(board[i][j] == PIECE_KING) begin
					end
				end
			end
		end
	end
	
	end 
endmodule
