module check(
clock,
piece,
player,
moveSet
);
input clock;
input [3:0] piece;
input player;
output reg [11:0] moveSet;

wire clock;
reg [3:0] pieceInput;
reg [11:0] move;
localparam PIECE_PAWN	= 3'b001;
localparam PIECE_ROOK	= 3'b010;
localparam PIECE_KNIGHT	= 3'b011;
localparam PIECE_BISHOP	= 3'b100;
localparam PIECE_QUEEN	= 3'b101;
localparam PIECE_KING	= 3'b110;

always @(posedge clock)
begin 
	if(piece == PIECE_PAWN)begin
		moveSet <= 12'b001001000001;
	end else if(piece == PIECE_ROOK) begin
		moveSet <= 12'b111111111111;
	end else if(piece == PIECE_KNIGHT) begin
		moveSet <= 12'b011011011011;
	end else if(piece == PIECE_BISHOP) begin
		moveSet <= 12'b111111111111;
	end else if(piece == PIECE_KING) begin
		moveSet <= 12'b001001001001;

	end
end 
endmodule