`timescale 1 ns / 1 ps

module LCD(clk12, reset, BGR, HSYNC, VSYNC, DISP, cursor, enter_pressed, esc_pressed, en, confirm_pressed, move_pressed, lvb, lvw, avb, avw, 
player_in, pid, found_piece, moveSet, init_begin);
input clk12, reset, enter_pressed, esc_pressed, confirm_pressed, move_pressed;
input [5:0] cursor;
input [95:0] lvw, lvb;
input [15:0] avw, avb;
input player_in;
input en;
input [127:0] moveSet;
output wire [23:0] BGR;
output wire HSYNC, VSYNC, DISP;
output reg [3:0] pid;
output reg found_piece;
output wire init_begin;

 
parameter RESET = 2'b00;
parameter SEND_LINE = 2'b01;
parameter SEND_VSYNC = 3'b10;
parameter hCountMax = 525;
parameter vCountMax = 285;

parameter hImage_Area 		= 480;
parameter hFront_Porch   	= 2;
parameter hSync_Pulse		= 1;

parameter vImage_Area		= 272;
parameter vFront_Porch		= 1;
parameter vSync_Pulse		= 1;

parameter startUpMax = 16;

//Board
parameter pxWidth = 33;
parameter borderWidth = 4;

//definition of piece id
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

reg board[7:0][7:0];

reg[127:0] Bmoves[7:0];


integer counter = 0;

wire [95:0] location_vectors_w;
wire [95:0] location_vectors_b;
wire [15:0] alive_vectors_w;
wire [15:0] alive_vectors_b;
wire [127:0] ms_in;

reg [7:0] pawn_w_piece [7:0];
reg [7:0] pawn_b_piece [7:0];
reg [7:0] rook_piece [7:0];
reg [7:0] knight_piece [7:0];
reg [7:0] bishop_piece [7:0];
reg [7:0] queen_piece [7:0];
reg [7:0] king_piece [7:0]; 
	
reg[7:0] local_piece;

wire player;
reg previousPlayer;

reg[95:0] BLACK    = 96'b101111_101110_101101_101100_101011_101010_101001_101000_100111_100110_100101_100100_100011_100010_100001_100000;
reg[95:0] WHITE    = 96'b111111_111110_111101_111100_111011_111010_111001_111000_110111_110110_110101_110100_110011_110010_110001_110000;
reg[5:0] temppid = 6'b000000;
reg tempPieceUnder = 1'b0;


reg [1:0] state = RESET;
integer hCount = 0;
integer vCount = 0; 
integer startUp = 0;
integer pixNum = 0;
reg hS, vS;
reg [23:0] cBGR;
reg cDISP;

reg [6:0] cursor_colour[31:0];
reg [6:0] cursor_best[31:0];

reg temp_init_begin;
wire tert_pressed;

assign tert_pressed = ~confirm_pressed;

assign HSYNC = hS;
assign VSYNC = vS;
assign DISP = cDISP; //1: ON, 0: OFF
assign BGR = cBGR;

integer i, j, index, index_best;
reg[2:0] reg_i;

initial begin
	i <= 95;
	j <= 15;
	previousPlayer <= 1'b0;
	local_piece <= 8'h00;
	pawn_w_piece[0] <= 8'b00_00_00_00;
	pawn_w_piece[1] <= 8'b00_01_10_00;
	pawn_w_piece[2] <= 8'b01_01_10_10;
	pawn_w_piece[3] <= 8'b01_00_00_10;
	pawn_w_piece[4] <= 8'b00_11_11_00;
	pawn_w_piece[5] <= 8'b00_10_01_00;
	pawn_w_piece[6] <= 8'b00_11_11_00;
	pawn_w_piece[7] <= 8'b00_00_00_00;
	
	pawn_b_piece[0] <= 8'b00_00_00_00;
	pawn_b_piece[1] <= 8'b00_11_11_00;
	pawn_b_piece[2] <= 8'b00_10_01_00;
	pawn_b_piece[3] <= 8'b00_11_11_00;
	pawn_b_piece[4] <= 8'b01_00_00_10;
	pawn_b_piece[5] <= 8'b01_01_10_10;
	pawn_b_piece[6] <= 8'b00_01_10_00;
	pawn_b_piece[7] <= 8'b00_00_00_00;
	
	rook_piece[0] <= 8'b00_01_10_00;
	rook_piece[1] <= 8'b00_01_10_00;
	rook_piece[2] <= 8'b00_00_00_00;
	rook_piece[3] <= 8'b11_01_10_11;
	rook_piece[4] <= 8'b11_01_10_11;
	rook_piece[5] <= 8'b00_00_00_00;
	rook_piece[6] <= 8'b00_01_10_00;
	rook_piece[7] <= 8'b00_01_10_00;
	
	knight_piece[0] <= 8'b00_00_00_00;
	knight_piece[1] <= 8'b00_10_01_00;
	knight_piece[2] <= 8'b01_00_00_10;
	knight_piece[3] <= 8'b00_01_10_00;
	knight_piece[4] <= 8'b00_01_10_00;
	knight_piece[5] <= 8'b01_00_00_10;
	knight_piece[6] <= 8'b00_10_01_00;
	knight_piece[7] <= 8'b00_00_00_00;
	
	bishop_piece[0] <= 8'b10_00_00_01;
	bishop_piece[1] <= 8'b01_00_00_10;
	bishop_piece[2] <= 8'b00_10_01_00;
	bishop_piece[3] <= 8'b00_01_10_00;
	bishop_piece[4] <= 8'b00_01_10_00;
	bishop_piece[5] <= 8'b00_10_01_00;
	bishop_piece[6] <= 8'b01_00_00_10;
	bishop_piece[7] <= 8'b10_00_00_01;
	
	queen_piece[0] <= 8'b10_01_10_01;
	queen_piece[1] <= 8'b01_01_10_10;
	queen_piece[2] <= 8'b00_10_01_00;
	queen_piece[3] <= 8'b11_01_10_11;
	queen_piece[4] <= 8'b11_01_10_11;
	queen_piece[5] <= 8'b00_10_01_00;
	queen_piece[6] <= 8'b01_01_10_10;
	queen_piece[7] <= 8'b10_01_10_01;
	
	king_piece[0] <= 8'b00_00_00_00;
	king_piece[1] <= 8'b01_11_11_10;
	king_piece[2] <= 8'b01_00_00_10;
	king_piece[3] <= 8'b01_01_10_10;
	king_piece[4] <= 8'b01_01_10_10;
	king_piece[5] <= 8'b01_00_00_10;
	king_piece[6] <= 8'b01_11_11_10;
	king_piece[7] <= 8'b00_00_00_00;
	temp_init_begin <= 1'b1;
	
	Bmoves[0] <= 128'h44444444_000000_0208_000000_000000_00;
	Bmoves[1] <= 128'h44444444_000000_0280_000000_000000_00;
	Bmoves[2] <= 128'h44844444_000000_0208_000000_000000_00;
	Bmoves[3] <= 128'h44844444_040000_2080_000000_000000_00;
	Bmoves[4] <= 128'h44884444_000000_0208_0C0000_000000_00;
	Bmoves[5] <= 128'h84844088_200000_0208_000000_000000_00;
	Bmoves[6] <= 128'h84818888_000000_0208_200000_000000_00;
	Bmoves[7] <= 128'h84880048_001000_0208_140000_000000_00;
end

	
assign alive_vectors_w = avw;
assign alive_vectors_b = avb;
assign player = player_in;
assign location_vectors_w = lvw;
assign location_vectors_b = lvb;
assign ms_in = moveSet;
assign init_begin = temp_init_begin;
	

//Increment hCount and VCount values
always @(posedge clk12) begin
	if (reset) begin
		hCount <= 0;
		vCount <= 0;
	end
	else begin
		if (hCount < hCountMax) begin
			hCount <= hCount + 1;
		end
		else begin
			hCount <= 0;
			if (vCount < vCountMax) begin
				vCount <= vCount + 1;
			end
			else begin
				vCount <= 0;
			end
		end
	end
end

//Send hsync and vsync pulse
always @(posedge clk12) begin
  if (reset) begin
    hS <= 1'b1; //1: ON, 0: OFF
    vS <= 1'b1; //1: ON, 0: OFF
  end
  else begin
    if ((hCount > (hImage_Area + hFront_Porch)) && hCount <= (hImage_Area + hFront_Porch + hSync_Pulse)) begin
      hS <= 1'b1; //1: ON, 0: OFF
    end
    else begin
      hS <= 1'b0; //1: ON, 0: OFF
    end

    if ((vCount > (vImage_Area + vFront_Porch)) && vCount <= (vImage_Area + vFront_Porch + vSync_Pulse)) begin
      vS <= 1'b1; //1: ON, 0: OFF
    end
    else begin
      vS <= 1'b0; //1: ON, 0: OFF
    end
  end
end


always @(posedge move_pressed) begin
//initialize player colouring
	index = 0;
	index_best = 0;
	
	for (i = 31; i >= 0 ; i=i -1) begin
		cursor_colour[i] = 7'b0000000;
		cursor_best[i] = 7'b0000000;
	end
	
	if(tert_pressed == 1'b1 || temp_init_begin == 1'b1) begin
		case (temppid[3:0]) 
		P1: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end

				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P2: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P3: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P4: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P5: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P6: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P7: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		P8: begin
		if (player == 1'b1) begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		else begin
			if (location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]]) begin
				if (ms_in[127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index = index + 1;
				end
				if (ms_in[125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index = index + 1;
				end
				if (ms_in[124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index = index + 1;
				end
				
				if (Bmoves[counter][127-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][126-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0]};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][125-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
					index_best = index_best + 1;
				end
				if (Bmoves[counter][124-(15-temppid[3:0])*4] == 1'b1) begin
					cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
					index_best = index_best + 1;
				end
			end
		end
		end
		R1: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			for (i=1; i<=ms_in[95 -:3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[92 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[89 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[86 -: 3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0]};
				index = index+1;
			end
			
			if (Bmoves[counter][95 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] - Bmoves[counter][95 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][92 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] + Bmoves[counter][92 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][89 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][89 -: 3], cursor[2:0]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][86 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][86 -: 3], cursor[2:0]};
				index_best = index_best + 1;
			end
		end
		end
		R2: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			for (i=1; i<=ms_in[83 -:3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[80 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[77 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[74 -: 3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0]};
				index = index+1;
			end
			
			if (Bmoves[counter][83 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] - Bmoves[counter][83 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][80 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] + Bmoves[counter][80 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][77 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][77 -: 3], cursor[2:0]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][74 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][74 -: 3], cursor[2:0]};
				index_best = index_best + 1;
			end
		end
		end
		N1: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			if (ms_in[71] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] - 3'b001};
				index = index + 1;
			end
			if (ms_in[70] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b010};
				index = index + 1;
			end
			if (ms_in[69] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[68] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b010};
				index = index + 1;
			end
			if (ms_in[67] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] - 3'b001};
				index = index + 1;
			end
			if (ms_in[66] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b010};
				index = index + 1;
			end
			if (ms_in[65] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[64] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b010};
				index = index + 1;
			end
			
			if (Bmoves[counter][71] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][70] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b010};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][69] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][68] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b010};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][67] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][66] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b010};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][65] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][64] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b010};
				index_best = index_best + 1;
			end
		end
		end
		N2: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			if (ms_in[63] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] - 3'b001};
				index = index + 1;
			end
			if (ms_in[62] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b010};
				index = index + 1;
			end
			if (ms_in[61] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[60] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b010};
				index = index + 1;
			end
			if (ms_in[59] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] - 3'b001};
				index = index + 1;
			end
			if (ms_in[58] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b010};
				index = index + 1;
			end
			if (ms_in[57] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[56] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b010};
				index = index + 1;
			end
			
			if (Bmoves[counter][63] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][62] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b010};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][61] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b010, cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][60] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b010};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][59] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][58] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b010};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][57] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b010, cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][56] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b010};
				index_best = index_best + 1;
			end
		end
		end
		B1: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			for (i=1; i<=ms_in[55 -:3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[52 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[49 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[46 -: 3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			
			if (Bmoves[counter][55 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][55 -: 3], cursor[2:0] - Bmoves[counter][55 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][52 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][52 -: 3], cursor[2:0] + Bmoves[counter][52 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][49 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][49 -: 3], cursor[2:0] - Bmoves[counter][49 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][46 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][46 -: 3], cursor[2:0] + Bmoves[counter][46 -: 3]};
				index_best = index_best + 1;
			end
		end
		end
		B2: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			for (i=1; i<=ms_in[43 -:3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[40 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[37 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[34 -: 3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			
			if (Bmoves[counter][43 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][43 -: 3], cursor[2:0] - Bmoves[counter][43 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][40 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][40 -: 3], cursor[2:0] + Bmoves[counter][40 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][37 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][37 -: 3], cursor[2:0] - Bmoves[counter][37 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][34 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][34 -: 3], cursor[2:0] + Bmoves[counter][34 -: 3]};
				index_best = index_best + 1;
			end
		end
		end
		Q1: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			for (i=1; i<=ms_in[31 -:3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[28 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[25 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[22 -: 3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[19 -:3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[16 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + i[2:0], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[13 -: 3]; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0] - i[2:0]};
				index = index+1;
			end
			for (i=1; i<=ms_in[10 -: 3] ; i=i+1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - i[2:0], cursor[2:0] + i[2:0]};
				index = index+1;
			end
			
			if (Bmoves[counter][31 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] - Bmoves[counter][31 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][28 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] + Bmoves[counter][28 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][25 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][25 -: 3], cursor[2:0]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][22 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][22 -: 3], cursor[2:0]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][19 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][19 -: 3], cursor[2:0] - Bmoves[counter][19 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][16 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + Bmoves[counter][16 -: 3], cursor[2:0] + Bmoves[counter][16 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][13 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][13 -: 3], cursor[2:0] - Bmoves[counter][13 -: 3]};
				index_best = index_best + 1;
			end
			
			if (Bmoves[counter][10 -: 3] != 3'b000) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - Bmoves[counter][10 -: 3], cursor[2:0] + Bmoves[counter][10 -: 3]};
				index_best = index_best + 1;
			end
		end
		end
		K1: begin
		if ((location_vectors_w[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_w[temppid[3:0]]) || (location_vectors_b[(temppid[3:0]*6 + 5) -: 6] == cursor[5:0] && alive_vectors_b[temppid[3:0]])) begin
			if (ms_in[7] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
				index = index + 1;
			end
			if (ms_in[6] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
				index = index + 1;
			end
			if (ms_in[5] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[4] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[3] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
				index = index + 1;
			end
			if (ms_in[2] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
				index = index + 1;
			end
			if (ms_in[1] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
				index = index + 1;
			end
			if (ms_in[0] == 1'b1) begin
				cursor_colour[index] = {1'b1, cursor[5:3], cursor[2:0] - 3'b001};
				index = index + 1;
			end
			
			if (Bmoves[counter][7] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][6] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0]};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][5] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] + 3'b001, cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][4] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][3] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] + 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][2] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0]};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][1] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3] - 3'b001, cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
			if (Bmoves[counter][0] == 1'b1) begin
				cursor_best[index_best] = {1'b1, cursor[5:3], cursor[2:0] - 3'b001};
				index_best = index_best + 1;
			end
		end
		end
		endcase
	end
	
	if (previousPlayer != player) begin
		counter = counter + 1;
	end
	previousPlayer <= player;
end

//Send 
always @(posedge enter_pressed) begin
	//find piece
	tempPieceUnder = 1'b0;
	for(i = 95; i > 0; i = i-6) begin
			if (alive_vectors_w[i/6]) begin
				if(location_vectors_w[i -: 6] == cursor && (enter_pressed && confirm_pressed == 1'b0)) begin
					temppid = WHITE[i -: 6];
					tempPieceUnder = 1'b1;
				end
			end
			if (alive_vectors_b[i/6]) begin
				if(location_vectors_b[i -: 6] == cursor && (enter_pressed && confirm_pressed == 1'b0)) begin
					temppid = BLACK[i -: 6];
					tempPieceUnder = 1'b1;
				end
			end
	end
	found_piece = tempPieceUnder;
	pid = temppid[3:0];
	if ((temppid[3:0] != K1) || (temppid[3:0] != Q1) || (temppid[3:0] != R1)  || (temppid[3:0] != R2)  
	|| (temppid[3:0] != B1)  || (temppid[3:0] != B2)) begin
		temp_init_begin = 1'b0;
	end
end

always @(posedge clk12) begin
	if(reset) begin
		cDISP <= 1'b0;
	end
	else begin
		cDISP <= 1'b1;
		if (player == 1'b1) begin
			cBGR = 24'hFF_FF_FF;
		end
		else begin	
			cBGR = 24'h00_00_00;
		end
				
		if ((vCount <= 4 || vCount >= (vImage_Area - 4)) && (hCount > 104 && hCount < 376)) begin
			cBGR = 24'h00_FE_00; //Green border;
		end
		else begin
			if ((hCount >= 104 && hCount <= 108) || (hCount >= (hImage_Area/2 + vImage_Area/2 - 4) && hCount <= (hImage_Area/2 + vImage_Area/2))) begin
				cBGR = 24'h00_FE_00; //Green border;
			end
			else begin
				if (hCount >= 108 && hCount <= 372 && vCount >= 4 && vCount<= 268) begin
					if(((vCount >= 4 && vCount < 37) || (vCount >=70 && vCount < 103) || (vCount >=136 && vCount < 169) || (vCount >=202 && vCount < 235)) && ~((hCount >= 108 && hCount < 141) || (hCount >= 174 && hCount < 207) || (hCount >= 240 && hCount < 273) || (hCount >= 306 && hCount < 339)) == 1'b1) begin
						cBGR = 24'h11_44_8B;
					end
					else if(~((vCount >= 4 && vCount < 37) || (vCount >=70 && vCount < 103) || (vCount >=136 && vCount < 169) || (vCount >=202 && vCount < 235)) && ~((hCount >= 108 && hCount < 141) || (hCount >= 174 && hCount < 207) || (hCount >= 240 && hCount < 273) || (hCount >= 306 && hCount < 339)) == 1'b0) begin
						cBGR = 24'h11_44_8B;
					end
					else begin
						cBGR = 24'h67_97_CC;
					end
					
					for (i=31 ; i>=0 ; i = i-1) begin
						if (move_pressed == 1'b1) begin	
							if ((cursor_colour[i] & 7'b1000000) == 7'b1000000) begin //means the loc should be coloured
								if ((vCount >= (7 - cursor_colour[i][5 -:3])*pxWidth + 4) && (vCount < (8 - cursor_colour[i][5 -:3])*pxWidth + 4)
								&& (hCount >= (cursor_colour[i][(5 - 3) -: 3]*pxWidth + 108)) && (hCount < ((cursor_colour[i][(5 - 3) -: 3] + 1)*pxWidth + 108))) begin
									cBGR = 24'hFF_80_00;
								end
								
							end
							if ((cursor_best[i] & 7'b1000000) == 7'b1000000) begin //means the loc should be coloured
								if ((vCount >= (7 - cursor_best[i][5 -:3])*pxWidth + 4) && (vCount < (8 - cursor_best[i][5 -:3])*pxWidth + 4)
								&& (hCount >= (cursor_best[i][(5 - 3) -: 3]*pxWidth + 108)) && (hCount < ((cursor_best[i][(5 - 3) -: 3] + 1)*pxWidth + 108))) begin
									cBGR = 24'h80_00_80;
								end
								
							end
						end
						else if (move_pressed == 1'b0) begin
							if(((vCount >= 4 && vCount < 37) || (vCount >=70 && vCount < 103) || (vCount >=136 && vCount < 169) || (vCount >=202 && vCount < 235)) && ~((hCount >= 108 && hCount < 141) || (hCount >= 174 && hCount < 207) || (hCount >= 240 && hCount < 273) || (hCount >= 306 && hCount < 339)) == 1'b1) begin
								cBGR = 24'h11_44_8B;
							end
							else if(~((vCount >= 4 && vCount < 37) || (vCount >=70 && vCount < 103) || (vCount >=136 && vCount < 169) || (vCount >=202 && vCount < 235)) && ~((hCount >= 108 && hCount < 141) || (hCount >= 174 && hCount < 207) || (hCount >= 240 && hCount < 273) || (hCount >= 306 && hCount < 339)) == 1'b0) begin
								cBGR = 24'h11_44_8B;
							end
							else begin
								cBGR = 24'h67_97_CC;
							end
						end
					end
					
					if (((cursor[5:3] - (7 - ((vCount - 4)/pxWidth))) == 0) && ((cursor[2:0] - ((hCount - 108)/pxWidth)) == 0)) begin
						if (enter_pressed == 1'b1) begin
							if ((vCount >= (7 - cursor[5 -:3])*pxWidth + 7) && (vCount < (8 - cursor[5 -:3])*pxWidth + 1)
							&& (hCount >= (cursor[(5 - 3) -: 3]*pxWidth + 111)) && (hCount < ((cursor[(5 - 3) -: 3] + 1)*pxWidth + 105))) begin
								cBGR = 24'h00_00_FF;
							end
						end
						else begin
							cBGR = 24'h3A_99_72;
						end
					end
					
					for (i = 95; i > 0; i = i - 6) begin
						if (alive_vectors_w[i/6] == 1'b1) begin
							if ((vCount >= (7 - location_vectors_w[i -:3])*pxWidth + 4) && (vCount < (8 - location_vectors_w[i -:3])*pxWidth + 4)
							&& (hCount >= (location_vectors_w[(i - 3) -: 3]*pxWidth + 108)) && (hCount < ((location_vectors_w[(i - 3) -: 3] + 1)*pxWidth + 108))) begin
								//Draw piece
								if ((i/6) > 7) begin //Pawn case
									local_piece <= pawn_w_piece[(vCount - (7 - location_vectors_w[i -:3])*pxWidth - 4)/4];
									if (local_piece[(hCount - (location_vectors_w[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
										cBGR <= 24'hFF_FF_FF;
									end
								end
								else begin
									if ((i/6) == 7 || (i/6) == 6) begin //Rook piece
										local_piece <= rook_piece[(vCount - (7 - location_vectors_w[i -:3])*pxWidth - 4)/4];
										if (local_piece[(hCount - (location_vectors_w[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
											cBGR <= 24'hFF_FF_FF;
										end
									end
									else begin
										if ((i/6) == 5 || (i/6) == 4) begin //Knight piece
											local_piece <= knight_piece[(vCount - (7 - location_vectors_w[i -:3])*pxWidth - 4)/4];
											if (local_piece[(hCount - (location_vectors_w[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
												cBGR <= 24'hFF_FF_FF;
											end
										end
										else begin
											if ((i/6) == 3 || (i/6) == 2) begin //Bishop piece
												local_piece <= bishop_piece[(vCount - (7 - location_vectors_w[i -:3])*pxWidth - 4)/4];
												if (local_piece[(hCount - (location_vectors_w[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
													cBGR <= 24'hFF_FF_FF;
												end
											end
											else begin
												if ((i/6) == 1) begin //Queen piece
													local_piece <= queen_piece[(vCount - (7 - location_vectors_w[i -:3])*pxWidth - 4)/4];
													if (local_piece[(hCount - (location_vectors_w[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
														cBGR <= 24'hFF_FF_FF;
													end
												end
												else begin
													if ((i/6) == 0) begin //King piece
														local_piece <= king_piece[(vCount - (7 - location_vectors_w[i -:3])*pxWidth - 4)/4];
														if (local_piece[(hCount - (location_vectors_w[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
															cBGR <= 24'hFF_FF_FF;
														end
													end											
												end
											end
										end
									end
								end
							end
						end
						
						if (alive_vectors_b[i/6] == 1'b1) begin
							if ((vCount >= (7 - location_vectors_b[i -:3])*pxWidth + 4) && (vCount < (8 - location_vectors_b[i -:3])*pxWidth + 4)
							&& (hCount >= (location_vectors_b[(i - 3) -: 3]*pxWidth + 108)) && (hCount < ((location_vectors_b[(i - 3) -: 3] + 1)*pxWidth + 108))) begin
								//Draw piece
								if ((i/6) > 7) begin //Pawn case
									local_piece <= pawn_b_piece[(vCount - (7 - location_vectors_b[i -:3])*pxWidth - 4)/4];
									if (local_piece[(hCount - (location_vectors_b[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
										cBGR <= 24'h00_00_00;
									end
								end
								else begin
									if ((i/6) == 7 || (i/6) == 6) begin //Rook piece
										local_piece <= rook_piece[(vCount - (7 - location_vectors_b[i -:3])*pxWidth - 4)/4];
										if (local_piece[(hCount - (location_vectors_b[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
											cBGR <= 24'h00_00_00;
										end
									end
									else begin
										if ((i/6) == 5 || (i/6) == 4) begin //Knight piece
											local_piece <= knight_piece[(vCount - (7 - location_vectors_b[i -:3])*pxWidth - 4)/4];
											if (local_piece[(hCount - (location_vectors_b[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
												cBGR <= 24'h00_00_00;
											end
										end
										else begin
											if ((i/6) == 3 || (i/6) == 2) begin //Bishop piece
												local_piece <= bishop_piece[(vCount - (7 - location_vectors_b[i -:3])*pxWidth - 4)/4];
												if (local_piece[(hCount - (location_vectors_b[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
													cBGR <= 24'h00_00_00;
												end
											end
											else begin
												if ((i/6) == 1) begin //Queen piece
													local_piece <= queen_piece[(vCount - (7 - location_vectors_b[i -:3])*pxWidth - 4)/4];
													if (local_piece[(hCount - (location_vectors_b[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
														cBGR <= 24'h00_00_00;
													end
												end
												else begin
													if ((i/6) == 0) begin //King piece
														local_piece <= king_piece[(vCount - (7 - location_vectors_b[i -:3])*pxWidth - 4)/4];
														if (local_piece[(hCount - (location_vectors_b[(i-3) -: 3]*pxWidth) - 108)/4] == 1'b1) begin
															cBGR <= 24'h00_00_00;
														end
													end											
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end			
	end
end
endmodule
