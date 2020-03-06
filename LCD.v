`timescale 1 ns / 1 ps

module LCD(clk12, reset, BGR, HSYNC, VSYNC, DISP, cursor, enter_pressed, esc_pressed);
input clk12, reset, enter_pressed, esc_pressed;
input [5:0] cursor;
output wire [23:0] BGR;
output wire HSYNC, VSYNC, DISP;

parameter RESET = 2'b00;
parameter SEND_LINE = 2'b01;
parameter SEND_VSYNC = 3'b10;
parameter hCountMax = 525;
parameter vCountMax = 285;

parameter hImage_Area 		= 480;
parameter hFront_Porch   	= 2;
parameter hSync_Pulse		= 1;
//parameter hBack_Porch		= 43;
//
parameter vImage_Area		= 272;
parameter vFront_Porch		= 1;
parameter vSync_Pulse		= 1;
//parameter vBack_Porch		= 12;

parameter startUpMax = 16;

//Board
parameter pxWidth = 33;
parameter borderWidth = 4;
//(8-row)*pxWidth, (8-col)*pxWidth
reg board[7:0][7:0];

//reg [5:0] cursor;
reg [95:0] location_vectors_w;
reg [95:0] location_vectors_b;
reg [15:0] alive_vectors_w;
reg [15:0] alive_vectors_b;

reg [7:0] pawn_w_piece [7:0];
reg [7:0] pawn_b_piece [7:0];
reg [7:0] rook_piece [7:0];
reg [7:0] knight_piece [7:0];
reg [7:0] bishop_piece [7:0];
reg [7:0] queen_piece [7:0];
reg [7:0] king_piece [7:0]; 
	
reg[7:0] local_piece;

reg player;

reg [1:0] state = RESET;
integer hCount = 0;
integer vCount = 0; 
integer startUp = 0;
integer pixNum = 0;
reg hS, vS;
reg [23:0] cBGR;
reg cDISP;

assign HSYNC = hS;
assign VSYNC = vS;
assign DISP = cDISP; //1: ON, 0: OFF
assign BGR = cBGR;
//reg pawn_w[1023:0];

//reg done = 1'b1;
integer i, j;
//reg [2:0] reg_i, reg_j;

//reg [12:0] pawn_w_addr;
//wire pawn_w_q;
//
//RAM ram_block(
//	.address(ram_addr),
//	.clock(clk12),
//	.wren(),
//	.data(),
//	.q(ram_q)
//);

initial begin
//	$readmemb("pawn_w.txt", pawn_w);
//	board[0][7] = 1'b1;
//	board[1][7] = 1'b1;
//	board[4][5] = 1'b1;
//	board[2][6] = 1'b1;
//	reg_i = 3'b000;
//	reg_j = 3'b000;
	location_vectors_w <= 96'h20928B30D38F0070460850C4;
	location_vectors_b <= 96'hC31CB3D35DB7E3FE7EEBDEFC;
	alive_vectors_w <= 16'hFFFF;
	alive_vectors_b <= 16'hFFFF;
	i <= 95;
	j <= 15;

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
	
	player <= 1'b0;
	
//	cursor <= 6'b100_100;
end

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

//Send board
always @(posedge clk12) begin
	if(reset) begin
		cDISP <= 1'b0;
	end
	else begin
		cDISP <= 1'b1;
		if (player == 1'b0) begin
			cBGR = 24'hFF_FF_FF;
		end
		else begin	
			cBGR = 24'h00_00_00;
		end
		
//
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
					
					if (((cursor[5:3] - (7 - ((vCount - 4)/pxWidth))) == 0) && ((cursor[2:0] - ((hCount - 108)/pxWidth)) == 0)) begin
						if (enter_pressed == 1'b1) begin
							cBGR = 24'h99_5E_C2;
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