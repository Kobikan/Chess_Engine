module generateMoves(clock,
                     reset,
                     enable,
                     player,
                     locationVectorWhite,
                     locationVectorBlack,
                     aliveVectorWhite,
                     aliveVectorBlack,
                     moveSet,
							intdebug,
							bitdebug);
    input clock;
    input reset;
    input enable;
    input player;
    input [95: 0]locationVectorWhite;
    input [95: 0]locationVectorBlack;
    input [15: 0]aliveVectorWhite;
    input [15: 0]aliveVectorBlack;
    output reg [127: 0]moveSet;
	 output reg [127: 0]bitdebug;
    output integer intdebug;

    wire clock;
    wire reset;
    wire enable;
    
    reg [3:0] pawn;
    reg [11:0]rook;
    reg [7:0]knight;
    reg [11:0]bishop;
    reg [23:0]queen;
    reg [7:0]king;
    
    wire [95: 0] tempLVW, tempLVB;
    wire [15: 0] tempAVW, tempAVB;
    
    reg[5:0] board [7:0][7:0]; // Occupied, Black or White, Piece ID
    reg[95:0] BLACK    = 96'b101111_101110_101101_101100_101011_101010_101001_101000_100111_100110_100101_100100_100011_100010_100001_100000;
    reg[95:0] WHITE    = 96'b111111_111110_111101_111100_111011_111010_111001_111000_110111_110110_110101_110100_110011_110010_110001_110000;
    parameter occupied = 1'b1;
    parameter empty    = 1'b0;
    
    integer i, j, k, local_p, pawnCounter = 0, rookCounter = 0, rook_flag = 1, knightCounter = 0, bishopCounter = 0, bishop_flag = 1, queen_flag = 1;
    
    initial begin
        pawn   = 1'h0;
        rook   = 3'h000;
        knight = 2'h00;
        bishop = 3'h000;
		  queen  = 6'h000000;
        king   = 2'h00;
		  bitdebug = 32'h00000000000000000000000000000000;
		  moveSet = 32'h00000000000000000000000000000000;
		  intdebug = 0;
    end
    
    assign tempLVB = locationVectorBlack;
    assign tempLVW = locationVectorWhite;
    assign tempAVB = aliveVectorBlack;
    assign tempAVW = aliveVectorWhite;
    
    always @(posedge enable)
    begin
        if (player)
            local_p = 1;
        else
            local_p = -1;
			// Board Initializing logic
			for(i = 7; i >= 0; i = i-1) begin
				for(j = 7; j >= 0; j = j-1) begin
					board[i][j] = 6'b000000;
				end
			end
			for(i = 95; i > 0; i = i-6) begin
				if (tempAVW[i/6]) begin
					board[tempLVW[i -: 3]][tempLVW[(i-3) -: 3]] = WHITE[i -:6];
				end
				if (tempAVB[i/6]) begin
					board[tempLVB[i -: 3]][tempLVB[(i-3) -: 3]] = BLACK[i -: 6];
				end
			end


        //Board Game Logic
        // White = 1; Black = 0
        pawnCounter = 0;
        for(i = 95; i > 47; i = i-6) begin
            if (local_p == 1) begin
                if (tempAVW[i/6]) begin
					     if (tempLVW[i -: 3] < 7) begin
							  if ((board[tempLVW[i-: 3]+ local_p][tempLVW[i-3 -: 3]] & 6'b100000) == 6'b000000) begin
									pawn[3] = 1'b1;
									if (tempLVW[i -: 3] < 6) begin
										if (((board[tempLVW[i -: 3] +(local_p * 2)][tempLVW[i-3 -: 3]] & 6'b100000) == 6'b000000) && (tempLVW[i -: 3] == 3'b001))
											 pawn[2] = 1'b1;
									end
							  end
						  
							  // Upper Left occupied
							  if (tempLVW[i-3 -: 3] > 0) begin
									if ((board[tempLVW[i -: 3]+ local_p][tempLVW[i-3 -: 3] - 1'b1] & 6'b110000) == 6'b100000) begin
										pawn[1] = 1'b1;
									end
							  end
							  
							  if (tempLVW[i-3 -: 3] < 7) begin
									if ((board[tempLVW[i -: 3]+ local_p][tempLVW[i-3 -: 3] +1] & 6'b110000) == 6'b100000)
										pawn[0] = 1'b1;
							  end
						  end
					 end
            end
            else begin			
					 if (tempAVB[i/6]) begin
						  if (tempLVB[i -: 3] > 0) begin
							  if ((board[tempLVB[i-: 3]+ local_p][tempLVB[i-3 -: 3]] & 6'b100000) == 6'b000000) begin
									pawn[3] = 1'b1;
									if (tempLVB[i -: 3] >1) begin
										if (((board[tempLVB[i -: 3] + (local_p * 2)][tempLVB[i-3 -: 3]] & 6'b100000) == 6'b000000) && (tempLVB[i -: 3] == 3'b110))
											 pawn[2] = 1'b1;
									end
							  end
						  
							  // Upper Left from Black occupied
							  if (tempLVB[i-3 -: 3] < 7) begin
									if ((board[tempLVB[i -: 3]+ local_p][tempLVB[i-3 -: 3] + 1'b1] & 6'b110000) == 6'b110000) begin
										pawn[1] = 1'b1;
									end
							  end
							  
							  if (tempLVB[i-3 -: 3] > 0) begin
									if ((board[tempLVB[i -: 3]+ local_p][tempLVB[i-3 -: 3] - 1'b1] & 6'b110000) == 6'b110000)
										pawn[0] = 1'b1;
							  end
						  end
					 end
				end
            moveSet[127-(4*pawnCounter) -: 4] = pawn;
            pawnCounter = pawnCounter + 1;
            pawn        = 4'b0000;
        end
        
        
        
        
		  //Rook
        rook_flag   = 1;
        rookCounter = 0;
			for(i = 47; i > 35; i = i-6) begin
            if (local_p == 1) begin
                if (tempAVW[i/6]) begin
                    for(j = 1; j < 8; j = j + 1) begin //Left
								if(tempLVW[i-3 -:3] != 0)begin
									if ((tempLVW[i-3 -:3] - j > 0) && rook_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[11:9] = rook[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													rook[11:9] = rook[11:9] + 3'b001;
													rook_flag  = 0; //Break;
										 end
									end
									else if((tempLVW[i-3 -:3] - j == 0)&& rook_flag == 1) begin
										 if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[11:9] = rook[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													rook[11:9] = rook[11:9] + 3'b001;
										 end
										 rook_flag = 0; //Break;
									end
								end
						  end
                    rook_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Right
                        if (tempLVW[i-3 -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[8:6] = rook[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
                                    rook[8:6] = rook[8:6] + 3'b001;
                                rook_flag = 0; //Break;
                            end
                        end
                    end
                    rook_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Up
                        if (tempLVW[i -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[5:3] = rook[5:3] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3]] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
                                    rook[5:3] = rook[5:3] + 3'b001;
                                rook_flag = 0; //Break;
                            end
                        end
                    end
                    rook_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Down
								if(tempLVW[i -:3] != 0)begin
									if ((tempLVW[i -:3] - j > 0) && rook_flag == 1) begin // If still on board.
										 bitdebug[2:0] = tempLVW[i -:3] - j;
										 intdebug = j;
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[2:0] = rook[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													rook[2:0] = rook[2:0] + 3'b001;
											  rook_flag = 0; //Break;
										 end
									end
									else if((tempLVW[i -:3] - j == 0)&& rook_flag == 1) begin
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[2:0] = rook[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													rook[2:0] = rook[2:0] + 3'b001;
										 end
										 rook_flag = 0; //Break;
									end
							  end
						  end
                    rook_flag = 1;
						  
                end // Alive Vector End
            end // Player End
            
            //Black
            else begin
					if (tempAVB[i/6]) begin
						 for(j = 1; j < 8; j = j + 1) begin //Left
								if(tempLVB[i-3 -:3] != 0)begin
									if ((tempLVB[i-3 -:3] - j > 0) && rook_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[11:9] = rook[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													rook[11:9] = rook[11:9] + 3'b001;
													rook_flag  = 0; //Break;
										 end
									end
									else if((tempLVB[i-3 -:3] - j == 0)&& rook_flag == 1) begin
										 if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[11:9] = rook[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													rook[11:9] = rook[11:9] + 3'b001;
										 end
										 rook_flag = 0; //Break;
									end
								end
						  end
                    rook_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Right
                        if (tempLVB[i-3 -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[8:6] = rook[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] + j] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
                                    rook[8:6] = rook[8:6] + 3'b001;
                                rook_flag = 0; //Break;
                            end
                        end
                    end
                    rook_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Up
                        if (tempLVB[i -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[5:3] = rook[5:3] + 3'b001;
                            else begin
                                if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3]] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
                                    rook[5:3] = rook[5:3] + 3'b001;
                                rook_flag = 0; //Break;
                            end
                        end
                    end
                    rook_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Down
								if(tempLVB[i -:3] != 0)begin
									if ((tempLVB[i -:3] - j > 0) && rook_flag == 1) begin // If still on board.
										 bitdebug[2:0] = tempLVB[i -:3] - j;
										 intdebug = j;
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[2:0] = rook[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													rook[2:0] = rook[2:0] + 3'b001;
											  rook_flag = 0; //Break;
										 end
									end
									else if((tempLVB[i -:3] - j == 0)&& rook_flag == 1) begin
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  rook[2:0] = rook[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													rook[2:0] = rook[2:0] + 3'b001;
										 end
										 rook_flag = 0; //Break;
									end
							  end
						  end
                    rook_flag = 1;
					end
				end
				moveSet[95 - (rookCounter*12) -: 12] = rook;
				rook                                 = 12'b0000_0000_0000;
				rookCounter                          = rookCounter + 1;
			end
    
    // Knight
    for(i = 35; i > 23; i = i-6) begin
        if (local_p == 1) begin
            if (tempAVW[i/6]) begin
                // Up: 2 Left: 1
                if (((tempLVW[i-: 3] + 2) < 8) && ((tempLVW[i-3 -: 3]) > 0))begin
                    if ((board[tempLVW[i-: 3] + 2][tempLVW[i-3 -: 3] - 1] & 6'b010000) != 6'b010000)begin
                        knight[7] = 1'b1;
                    end
                end
                // Up: 1 Left: 2
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3]) > 1))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] - 2] & 6'b010000) != 6'b010000)begin
                        knight[6] = 1'b1;
                    end
                end
                // Up: 2 Right: 1
                if (((tempLVW[i-: 3] + 2) < 8) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] + 2][tempLVW[i-3 -: 3] + 1] & 6'b010000) != 6'b010000)begin
                        knight[5] = 1'b1;
                    end
                end
                // Up: 1 Right: 2
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] + 2] & 6'b010000) != 6'b010000)begin
                        knight[4] = 1'b1;
                    end
                end
                // Down: 2 Left: 1
                if (((tempLVW[i-: 3]) > 1) && ((tempLVW[i-3 -: 3]) > 0))begin
                    if ((board[tempLVW[i-: 3] - 2][tempLVW[i-3 -: 3] - 1] & 6'b010000) != 6'b010000)begin
                        knight[3] = 1'b1;
                    end
                end
                // Down: 1 Left: 2
                if (((tempLVW[i-: 3]) > 0) && ((tempLVW[i-3 -: 3]) > 1))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] - 2] & 6'b010000) != 6'b010000)begin
                        knight[2] = 1'b1;
                    end
                end
                // Down: 2 Right: 1
                if (((tempLVW[i-: 3]) > 1) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] - 2][tempLVW[i-3 -: 3] + 1] & 6'b010000) != 6'b010000)begin
                        knight[1] = 1'b1;
                    end
                end
                // Down: 1 Right: 2
                if (((tempLVW[i-: 3]) > 0) && ((tempLVW[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] + 2] & 6'b010000) != 6'b010000)begin
                        knight[0] = 1'b1;
                    end
                end
            end
        end
        else begin
            if (tempAVB[i/6]) begin
                // Up: 2 Left: 1
                if (((tempLVB[i-: 3] + 2) < 8) && ((tempLVB[i-3 -: 3]) > 0))begin
                    if ((board[tempLVB[i-: 3] + 2][tempLVB[i-3 -: 3] - 1] & 6'b110000) != 6'b100000)begin
                        knight[7] = 1'b1;
                    end
                end
                // Up: 1 Left: 2
                if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3]) > 1))begin
                    if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] - 2] & 6'b110000) != 6'b100000)begin
                        knight[6] = 1'b1;
                    end
                end
                // Up: 2 Right: 1
                if (((tempLVB[i-: 3] + 2) < 8) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVB[i-: 3] + 2][tempLVB[i-3 -: 3] + 1] & 6'b110000) != 6'b100000)begin
                        knight[5] = 1'b1;
                    end
                end
                // Up: 1 Right: 2
                if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] + 2] & 6'b110000) != 6'b100000)begin
                        knight[4] = 1'b1;
                    end
                end
                // Down: 2 Left: 1
                if (((tempLVB[i-: 3]) > 1) && ((tempLVB[i-3 -: 3]) > 0))begin
                    if ((board[tempLVB[i-: 3] - 2][tempLVB[i-3 -: 3] - 1] & 6'b110000) != 6'b100000)begin
                        knight[3] = 1'b1;
                    end
                end
                // Down: 1 Left: 2
                if (((tempLVB[i-: 3]) > 0) && ((tempLVB[i-3 -: 3]) > 1))begin
                    if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] - 2] & 6'b110000) != 6'b100000)begin
                        knight[2] = 1'b1;
                    end
                end
                // Down: 2 Right: 1
                if (((tempLVB[i-: 3]) > 1) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVB[i-: 3] - 2][tempLVB[i-3 -: 3] + 1] & 6'b110000) != 6'b100000)begin
                        knight[1] = 1'b1;
                    end
                end
                // Down: 1 Right: 2
                if (((tempLVB[i-: 3]) > 0) && ((tempLVB[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] + 2] & 6'b110000) != 6'b100000)begin
                        knight[0] = 1'b1;
                    end
                end
            end
        end
        moveSet[71- (8*knightCounter) -: 8] = knight;
        knightCounter = knightCounter + 1;
		  bitdebug[7:0] = knight;
        knight        = 2'h00;
    end
	 
		  //Bishop
        bishop_flag = 1;
        bishopCounter = 0;
			for(i = 23; i > 11; i = i-6) begin
            if (local_p == 1) begin
                if (tempAVW[i/6]) begin
                    for(j = 1; j < 8; j = j + 1) begin //Upper Left
								if(tempLVW[i-3 -:3] != 0)begin
									if ((tempLVW[i -:3] + j < 8) && (tempLVW[i-3 -:3] - j > 0) && bishop_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[11:9] = bishop[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													bishop[11:9] = bishop[11:9] + 3'b001;
											  bishop_flag  = 0; //Break;
										 end
									end
									else if((tempLVW[i-3 -:3] - j == 0)&& bishop_flag == 1) begin
										 if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[11:9] = bishop[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													bishop[11:9] = bishop[11:9] + 3'b001;
										 end
										 bishop_flag = 0; //Break;
									end
									else
										bishop_flag = 0;
								end
						  end
                    bishop_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Upper Right
                        if ((tempLVW[i -:3] + j < 8) &&(tempLVW[i-3 -:3] + j < 8) && bishop_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3]+j][tempLVW[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                bishop[8:6] = bishop[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3]+j][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
                                    bishop[8:6] = bishop[8:6] + 3'b001;
                                bishop_flag = 0; //Break;
                            end
                        end
                    end
                    bishop_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Lower Left
								if(tempLVW[i -:3] != 0 && tempLVW[i-3 -:3] != 0)begin
									if ((tempLVW[i -:3] - j > 0) && (tempLVW[i-3 -:3] - j > 0) && bishop_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[5:3] = bishop[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													bishop[5:3] = bishop[5:3] + 3'b001;
													bishop_flag  = 0; //Break;
										 end
									end
									else if(((tempLVW[i -:3] - j == 0) || (tempLVW[i-3 -:3] - j == 0))&& bishop_flag == 1) begin
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[5:3] = bishop[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													bishop[5:3] = bishop[5:3] + 3'b001;
										 end
										 bishop_flag = 0; //Break;
									end
									else
										bishop_flag = 0;
								end
                    end
                    bishop_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Lower Right
								if(tempLVW[i -:3] != 0)begin
									if ((tempLVW[i -:3] - j > 0) && (tempLVW[i-3 -:3] + j < 8) && bishop_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[2:0] = bishop[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													bishop[2:0] = bishop[2:0] + 3'b001;
													bishop_flag  = 0; //Break;
										 end
									end
									else if((tempLVW[i -:3] - j == 0)&& bishop_flag == 1) begin
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[2:0] = bishop[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													bishop[2:0] = bishop[2:0] + 3'b001;
										 end
										 bishop_flag = 0; //Break;
									end
									else
										bishop_flag = 0;
								end
						  end
                    bishop_flag = 1;
						  
                end // Alive Vector End
            end // Player End
            
            //Black
            else begin
					if (tempAVB[i/6]) begin
                    for(j = 1; j < 8; j = j + 1) begin //Upper Left
								if(tempLVB[i-3 -:3] != 0)begin
									if ((tempLVB[i -:3] + j < 8) && (tempLVB[i-3 -:3] - j > 0) && bishop_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[11:9] = bishop[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													bishop[11:9] = bishop[11:9] + 3'b001;
											  bishop_flag  = 0; //Break;
										 end
									end
									else if((tempLVB[i-3 -:3] - j == 0)&& bishop_flag == 1) begin
										 if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[11:9] = bishop[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													bishop[11:9] = bishop[11:9] + 3'b001;
										 end
										 bishop_flag = 0; //Break;
									end
									else
										bishop_flag = 0;
								end
						  end
                    bishop_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Upper Right
                        if ((tempLVB[i -:3] + j < 8) &&(tempLVB[i-3 -:3] + j < 8) && bishop_flag == 1) begin // If still on board.
                            if ((board[tempLVB[i -: 3]+j][tempLVB[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                bishop[8:6] = bishop[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVB[i -: 3]+j][tempLVB[i-3 -:3] + j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
                                    bishop[8:6] = bishop[8:6] + 3'b001;
                                bishop_flag = 0; //Break;
                            end
                        end
                    end
                    bishop_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Lower Left
								if(tempLVB[i -:3] != 0 && tempLVB[i-3 -:3] != 0)begin
									if ((tempLVB[i -:3] - j > 0) && (tempLVB[i-3 -:3] - j > 0) && bishop_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[5:3] = bishop[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													bishop[5:3] = bishop[5:3] + 3'b001;
													bishop_flag  = 0; //Break;
										 end
									end
									else if(((tempLVB[i -:3] - j == 0) || (tempLVB[i-3 -:3] - j == 0))&& bishop_flag == 1) begin
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[5:3] = bishop[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													bishop[5:3] = bishop[5:3] + 3'b001;
										 end
										 bishop_flag = 0; //Break;
									end
									else
										bishop_flag = 0;
								end
                    end
                    bishop_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Lower Right
								if(tempLVB[i -:3] != 0)begin
									if ((tempLVB[i -:3] - j > 0) && (tempLVB[i-3 -:3] + j < 8) && bishop_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[2:0] = bishop[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] + j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													bishop[2:0] = bishop[2:0] + 3'b001;
													bishop_flag  = 0; //Break;
										 end
									end
									else if((tempLVB[i -:3] - j == 0)&& bishop_flag == 1) begin
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  bishop[2:0] = bishop[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] + j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													bishop[2:0] = bishop[2:0] + 3'b001;
										 end
										 bishop_flag = 0; //Break;
									end
									else
										bishop_flag = 0;
								end
						  end
                    bishop_flag = 1;
					end
				end
				moveSet[55 - (bishopCounter*12) -: 12] = bishop;
				bishop                                 = 12'b0000_0000_0000;
				bishopCounter                          = bishopCounter + 1;
			end
	 
	 // Queen
    queen_flag   = 1;
			for(i = 11; i > 6; i = i-6) begin
            if (local_p == 1) begin
                if (tempAVW[i/6]) begin
                 for(j = 1; j < 8; j = j + 1) begin //Left
								if(tempLVW[i-3 -:3] != 0)begin
									if ((tempLVW[i-3 -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[23:21] = queen[23:21] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[23:21] = queen[23:21] + 3'b001;
													queen_flag  = 0; //Break;
										 end
									end
									else if((tempLVW[i-3 -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[23:21] = queen[23:21] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[23:21] = queen[23:21] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
								end
						  end
                    queen_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Right
                        if (tempLVW[i-3 -:3] + j < 8 && queen_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                queen[20:18] = queen[20:18] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
                                    queen[20:18] = queen[20:18] + 3'b001;
                                queen_flag = 0; //Break;
                            end
                        end
                    end
                    queen_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Up
                        if (tempLVW[i -:3] + j < 8 && queen_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                queen[17:15] = queen[17:15] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3]] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
                                    queen[17:15] = queen[17:15] + 3'b001;
                                queen_flag = 0; //Break;
                            end
                        end
                    end
                    queen_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Down
								if(tempLVW[i -:3] != 0)begin
									if ((tempLVW[i -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 bitdebug[2:0] = tempLVW[i -:3] - j;
										 intdebug = j;
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[14:12] = queen[14:12] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[14:12] = queen[14:12] + 3'b001;
											  queen_flag = 0; //Break;
										 end
									end
									else if((tempLVW[i -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[14:12] = queen[14:12] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[14:12] = queen[14:12] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
							  end
						  end
                    queen_flag = 1;
						  
                    for(j = 1; j < 8; j = j + 1) begin //Upper Left
								if(tempLVW[i-3 -:3] != 0)begin
									if ((tempLVW[i -:3] + j < 8) && (tempLVW[i-3 -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[11:9] = queen[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[11:9] = queen[11:9] + 3'b001;
											  queen_flag  = 0; //Break;
										 end
									end
									else if((tempLVW[i-3 -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[11:9] = queen[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[11:9] = queen[11:9] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
									else
										queen_flag = 0;
								end
						  end
                    queen_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Upper Right
                        if ((tempLVW[i -:3] + j < 8) &&(tempLVW[i-3 -:3] + j < 8) && queen_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3]+j][tempLVW[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                queen[8:6] = queen[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3]+j][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
                                    queen[8:6] = queen[8:6] + 3'b001;
                                queen_flag = 0; //Break;
                            end
                        end
                    end
                    queen_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Lower Left
								if(tempLVW[i -:3] != 0 && tempLVW[i-3 -:3] != 0)begin
									if ((tempLVW[i -:3] - j > 0) && (tempLVW[i-3 -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[5:3] = queen[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[5:3] = queen[5:3] + 3'b001;
													queen_flag  = 0; //Break;
										 end
									end
									else if(((tempLVW[i -:3] - j == 0) || (tempLVW[i-3 -:3] - j == 0))&& queen_flag == 1) begin
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[5:3] = queen[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[5:3] = queen[5:3] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
									else
										queen_flag = 0;
								end
                    end
                    queen_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Lower Right
								if(tempLVW[i -:3] != 0)begin
									if ((tempLVW[i -:3] - j > 0) && (tempLVW[i-3 -:3] + j < 8) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[2:0] = queen[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[2:0] = queen[2:0] + 3'b001;
													queen_flag  = 0; //Break;
										 end
									end
									else if((tempLVW[i -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[2:0] = queen[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] & 6'b010_000) != 6'b010_000) //If next space is occupied by black piece.
													queen[2:0] = queen[2:0] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
									else
										queen_flag = 0;
								end
						  end
                    queen_flag = 1;
						  
                end // Alive Vector End
            end // Player End
            
            //Black
            else begin
					if (tempAVB[i/6]) begin
					for(j = 1; j < 8; j = j + 1) begin //Left
								if(tempLVB[i-3 -:3] != 0)begin
									if ((tempLVB[i-3 -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[23:21] = queen[23:21] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													queen[23:21] = queen[23:21] + 3'b001;
													queen_flag  = 0; //Break;
										 end
									end
									else if((tempLVB[i-3 -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[23:21] = queen[23:21] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													queen[23:21] = queen[23:21] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
								end
						  end
                    queen_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Right
                        if (tempLVB[i-3 -:3] + j < 8 && queen_flag == 1) begin // If still on board.
                            if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                queen[20:18] = queen[20:18] + 3'b001;
                            else begin
                                if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] + j] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
                                    queen[20:18] = queen[20:18] + 3'b001;
                                queen_flag = 0; //Break;
                            end
                        end
                    end
                    queen_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Up
                        if (tempLVB[i -:3] + j < 8 && queen_flag == 1) begin // If still on board.
                            if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                queen[17:15] = queen[17:15] + 3'b001;
                            else begin
                                if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3]] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
                                    queen[17:15] = queen[17:15] + 3'b001;
                                queen_flag = 0; //Break;
                            end
                        end
                    end
                    queen_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Down
								if(tempLVB[i -:3] != 0)begin
									if ((tempLVB[i -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 intdebug = j;
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[14:12] = queen[14:12] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													queen[14:12] = queen[14:12] + 3'b001;
											  queen_flag = 0; //Break;
										 end
									end
									else if((tempLVB[i -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[14:12] = queen[14:12] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] & 6'b010_000) != 6'b000_000) //If next space is occupied by black piece.
													queen[14:12] = queen[14:12] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
							  end
						  end
                    queen_flag = 1;
                    for(j = 1; j < 8; j = j + 1) begin //Upper Left
								if(tempLVB[i-3 -:3] != 0)begin
									if ((tempLVB[i -:3] + j < 8) && (tempLVB[i-3 -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[11:9] = queen[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													queen[11:9] = queen[11:9] + 3'b001;
											  queen_flag  = 0; //Break;
										 end
									end
									else if((tempLVB[i-3 -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[11:9] = queen[11:9] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													queen[11:9] = queen[11:9] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
									else
										queen_flag = 0;
								end
						  end
                    queen_flag = 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Upper Right
                        if ((tempLVB[i -:3] + j < 8) &&(tempLVB[i-3 -:3] + j < 8) && queen_flag == 1) begin // If still on board.
                            if ((board[tempLVB[i -: 3]+j][tempLVB[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                queen[8:6] = queen[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVB[i -: 3]+j][tempLVB[i-3 -:3] + j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
                                    queen[8:6] = queen[8:6] + 3'b001;
                                queen_flag = 0; //Break;
                            end
                        end
                    end
                    queen_flag = 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Lower Left
								if(tempLVB[i -:3] != 0 && tempLVB[i-3 -:3] != 0)begin
									if ((tempLVB[i -:3] - j > 0) && (tempLVB[i-3 -:3] - j > 0) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[5:3] = queen[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													queen[5:3] = queen[5:3] + 3'b001;
													queen_flag  = 0; //Break;
										 end
									end
									else if(((tempLVB[i -:3] - j == 0) || (tempLVB[i-3 -:3] - j == 0))&& queen_flag == 1) begin
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[5:3] = queen[5:3] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] - j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													queen[5:3] = queen[5:3] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
									else
										queen_flag = 0;
								end
                    end
                    queen_flag = 1;

                    for(j = 1; j < 8; j = j +1) begin //Lower Right
								if(tempLVB[i -:3] != 0)begin
									if ((tempLVB[i -:3] - j > 0) && (tempLVB[i-3 -:3] + j < 8) && queen_flag == 1) begin // If still on board.
										 if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[2:0] = queen[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] + j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													queen[2:0] = queen[2:0] + 3'b001;
													queen_flag  = 0; //Break;
										 end
									end
									else if((tempLVB[i -:3] - j == 0)&& queen_flag == 1) begin
										 if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] + j] & 6'b100_000) == 6'b000_000) //If next space is not occupied.
											  queen[2:0] = queen[2:0] + 3'b001;
										 else begin
											  if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3] + j] & 6'b110_000) != 6'b100_000) //If next space is occupied by black piece.
													queen[2:0] = queen[2:0] + 3'b001;
										 end
										 queen_flag = 0; //Break;
									end
									else
										queen_flag = 0;
								end
						  end
                    queen_flag = 1;
					end
				end
				moveSet[31 -: 24] = queen;
				queen             = 12'b0000_0000_0000;
			end	 
	 
	 
     // King
    for(i = 5; i > 0; i = i-6) begin
        if (local_p == 1) begin
            if (tempAVW[i/6]) begin
                // Upper Left
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3]) > 0))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] - 1] & 6'b010000) != 6'b010000)begin
                        king[7] = 1'b1;
                    end
                end
                // Up
                if ((tempLVW[i-: 3] + 1) < 8)begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3]] & 6'b010000) != 6'b010000)begin
                        king[6] = 1'b1;
                    end
                end
                // Upper Right
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] + 1] & 6'b010000) != 6'b010000)begin
                        king[5] = 1'b1;
                    end
                end
                // Right
                if ((tempLVW[i-3 -: 3] + 1) < 8)begin
                    if ((board[tempLVW[i-: 3]][tempLVW[i-3 -: 3] + 1] & 6'b010000) != 6'b010000)begin
                        king[4] = 1'b1;
                    end
                end
                // Lower Right
                if (((tempLVW[i-: 3]) > 0) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] + 1] & 6'b010000) != 6'b010000)begin
                        king[3] = 1'b1;
                    end
                end
                // Down
                if ((tempLVW[i-: 3]) > 0) begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3]] & 6'b010000) != 6'b010000)begin
                        king[2] = 1'b1;
                    end
                end
                // Lower Left
                if (((tempLVW[i-: 3]) > 0) && ((tempLVW[i-3 -: 3]) > 0))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] - 1] & 6'b010000) != 6'b010000)begin
                        king[1] = 1'b1;
                    end
                end
                // Left
                if ((tempLVW[i-3 -: 3]) > 0)begin
                    if ((board[tempLVW[i-: 3]][tempLVW[i-3 -: 3] - 1] & 6'b010000) != 6'b010000)begin
                        king[0] = 1'b1;
                    end
                end
				end
         end
         else begin
				 if (tempAVB[i/6]) begin
					  // Upper Left
					  if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3]) > 0))begin
							if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] - 1] & 6'b110000) != 6'b100000)begin
								 king[7] = 1'b1;
							end
					  end
					  // Up
					  if ((tempLVB[i-: 3] + 1) < 8)begin
							if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3]] & 6'b110000) != 6'b100000)begin
								 king[6] = 1'b1;
							end
					  end
					  // Upper Right
					  if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
							if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] + 1] & 6'b110000) != 6'b100000)begin
								 king[5] = 1'b1;
							end
					  end
					  // Right
					  if ((tempLVB[i-3 -: 3] + 1) < 8)begin
							if ((board[tempLVB[i-: 3]][tempLVB[i-3 -: 3] + 1] & 6'b110000) != 6'b100000)begin
								 king[4] = 1'b1;
							end
					  end
					  // Lower Right
					  if (((tempLVB[i-: 3]) > 0) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
							if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] + 1] & 6'b110000) != 6'b100000)begin
								 king[3] = 1'b1;
							end
					  end
					  // Down
					  if ((tempLVB[i-: 3]) > 0)begin
							if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3]] & 6'b110000) != 6'b100000)begin
								 king[2] = 1'b1;
							end
					  end
					  // Lower Left
					  if (((tempLVB[i-: 3]) > 0) && ((tempLVB[i-3 -: 3]) > 0))begin
							if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] - 1] & 6'b110000) != 6'b100000)begin
								 king[1] = 1'b1;
							end
					  end
					  // Left
					  if ((tempLVB[i-3 -: 3]) > 0)begin
							if ((board[tempLVB[i-: 3]][tempLVB[i-3 -: 3] - 1] & 6'b110000) != 6'b100000)begin
								 king[0] = 1'b1;
							end
					  end
                end
            end
            moveSet[7 -: 8] = king;
            king = 2'h00;
        end
		  
		  pawnCounter = 0;
		  rookCounter = 0;
		  knightCounter = 0;
		  bishopCounter = 0;
    end // Always Block End
endmodule
