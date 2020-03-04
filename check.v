module check(reset,
             enable,
             player,
             locationVectorWhite,
             locationVectorBlack,
             aliveVectorWhite,
             aliveVectorBlack,
             isCheck,
				 isCheckDir,
             intdebug,
             bitdebug);
  input reset;
  input enable;
  input player;
  input [95: 0]locationVectorWhite;
  input [95: 0]locationVectorBlack;
  input [15: 0]aliveVectorWhite;
  input [15: 0]aliveVectorBlack;
  output reg [15: 0]isCheck;
  output reg [7: 0]isCheckDir;
  output reg [127: 0]bitdebug;
  output integer intdebug;

  wire reset;
  wire enable;

  wire [95: 0] tempLVW, tempLVB;
  wire [15: 0] tempAVW, tempAVB;

  reg[5:0] board [7:0][7:0]; // Occupied, Black or White, Piece ID
  reg[95:0] BLACK    = 96'b101111_101110_101101_101100_101011_101010_101001_101000_100111_100110_100101_100100_100011_100010_100001_100000;
  reg[95:0] WHITE    = 96'b111111_111110_111101_111100_111011_111010_111001_111000_110111_110110_110101_110100_110011_110010_110001_110000;
  parameter occupied = 1'b1;
  parameter empty    = 1'b0;

  integer i, j, k, local_p, pawnCounter = 0, rookCounter = 0, rook_flag = 1, knightCounter = 0, bishopCounter = 0, bishop_flag = 1, king_flag = 1;

  initial begin
    isCheck = 4'h0000;
    isCheckDir = 2'h00;

  end

  assign tempLVB = locationVectorBlack;
  assign tempLVW = locationVectorWhite;
  assign tempAVB = aliveVectorBlack;
  assign tempAVW = aliveVectorWhite;

  always @(posedge enable)
    begin
      isCheck = 4'h0000;
      isCheckDir = 2'h00; // Clockwise Up - UpperRight...
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

      king_flag   = 1;
      if (player) begin
        for(j = 1; j < 8; j = j + 1) begin //Left
          if(tempLVW[2 :0] != 0)begin
            if ((tempLVW[5 :3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b110_000)begin //If next space is occupied by White piece.
                king_flag  = 0; //Break;
              end
              else if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b100_000)begin //If next space is occupied by Black piece.
                if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b001_111) == 6'b000_111)begin//Rook 1
                  isCheckDir[1] = 1'b1;
                  isCheck[7] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b001_111) == 6'b000_110)begin//Rook 2  
                  isCheck[6] = 1'b1;
                  isCheckDir[1] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1;
                  isCheckDir[1] = 1'b1;
                end
                king_flag  = 0; //Break;
              end
            end
            else if((tempLVW[5-3 -:3] == j)&& king_flag == 1) begin
              if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) //If next space is occupied by White piece.
                king_flag  = 0; //Break;
              else if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b100_000)begin //If next space is occupied by Black piece.
                if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b001_111) == 6'b000_111)begin//Rook 1 
                  isCheck[7] = 1'b1;
                  isCheckDir[1] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b001_111) == 6'b000_110)begin//Rook 2  
                  isCheck[6] = 1'b1;
                  isCheckDir[1] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] - j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1;
                  isCheckDir[1] = 1'b1;
                end
              end
              king_flag = 0; //Break;

            end
          end
        end
        king_flag = 1;
        // End of Left  


        for(j = 1; j < 8; j = j + 1) begin //Right
          if (tempLVW[5-3 -:3] + j < 8 && king_flag == 1) begin // If still on board.
            if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) //If next space is white.
              king_flag = 0; //Break;
            else if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) begin//If next space is occupied by black piece.
              if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] + j] & 6'b001_111) == 6'b000_111)begin//Rook 1 
                isCheck[7] = 1'b1;
                isCheckDir[5] = 1'b1;
              end
              else if((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] + j] & 6'b001_111) == 6'b000_110)begin//Rook 2  
                isCheck[6] = 1'b1;
                isCheckDir[5] = 1'b1;
              end
              else if ((board[tempLVW[5 -: 3]][tempLVW[5-3 -:3] + j] & 6'b001_111) == 6'b000_001)begin//Queen 
                isCheck[1] = 1'b1;
                isCheckDir[5] = 1'b1;
              end
              king_flag = 0; //Break;
            end
          end
        end
        king_flag = 1;


        for(j = 1; j < 8; j = j +1) begin //Up
          if (tempLVW[5 -:3] + j < 8 && king_flag == 1) begin // If still on board.
            if ((board[tempLVW[5 -: 3] + j][tempLVW[5-3 -:3]] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
              king_flag = 0; //Break;
            else if ((board[tempLVW[5 -: 3] + j][tempLVW[5-3 -:3]] & 6'b110_000) == 6'b100_000) begin //If next space is occupied by black piece.
              if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_111)begin//Rook 1 
                isCheck[7] = 1'b1;
                isCheckDir[7] = 1'b1;
              end
              else if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_110)begin//Rook 2  
                isCheck[6] = 1'b1;
                isCheckDir[7] = 1'b1;
              end
              else if ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_001)begin//Queen 
                isCheck[1] = 1'b1;    
                isCheckDir[7] = 1'b1;
              end
              king_flag = 0; //Break;
            end
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j +1) begin //Down
          if(tempLVW[5 -:3] != 0)begin
            if ((tempLVW[5 -:3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3]] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3]] & 6'b110_000) == 6'b100_000)begin //If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_111)begin//Rook 1 
                  isCheck[7] = 1'b1;
                  isCheckDir[3] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_110)begin//Rook 2  
                  isCheck[6] = 1'b1;
                  isCheckDir[3] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1;              
                  isCheckDir[3] = 1'b1;
                end
                king_flag = 0; //Break;
              end
            end
            else if((tempLVW[5 -:3] - j == 0)&& king_flag == 1) begin
              if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3]] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3]] & 6'b110_000) == 6'b100_000)begin //If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_111)begin//Rook 1 
                  isCheck[7] = 1'b1;
                  isCheckDir[3] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_110)begin//Rook 2  
                  isCheck[6] = 1'b1;
                  isCheckDir[3] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1;              
                  isCheckDir[3] = 1'b1;
                end
                king_flag = 0; //Break;
              end
            end
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j + 1) begin //Upper Left
          if(tempLVW[5-3 -:3] != 0)begin
            if ((tempLVW[5 -:3] + j < 8) && (tempLVW[5-3 -:3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVW[5 -: 3] + j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVW[5 -: 3] + j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) begin//If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                  isCheck[3] = 1'b1;
                  isCheckDir[0] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                  isCheck[2] = 1'b1;
                  isCheckDir[0] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1; 
                  isCheckDir[0] = 1'b1;
                end
                else if (((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) <= 6'b001_111) && ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) >= 6'b000_111))begin//Pawn 
                  isCheck[board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j][3:0]] = 1'b1; 
                  isCheckDir[0] = 1'b1;
                end
                king_flag  = 0; //Break;
              end
            end
            else if((tempLVW[5-3 -:3] - j == 0)&& king_flag == 1) begin
              if ((board[tempLVW[5 -: 3] + j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag  = 0; //Break;
              else if ((board[tempLVW[5 -: 3] + j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) begin//If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                  isCheck[3] = 1'b1;
                  isCheckDir[0] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                  isCheck[2] = 1'b1;
                  isCheckDir[0] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1;
                  isCheckDir[0] = 1'b1;
                end
                else if (((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) <= 6'b001_111) && ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) >= 6'b000_111))begin//Pawn 
                  isCheck[board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j][3:0]] = 1'b1; 	
                  isCheckDir[0] = 1'b1;
                end	
                king_flag  = 0; //Break;
              end
            end
            else
              king_flag = 0;
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j + 1) begin //Upper Right
          if ((tempLVW[5 -:3] + j < 8) &&(tempLVW[5-3 -:3] + j < 8) && king_flag == 1) begin // If still on board.
            if ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
              king_flag  = 0; //Break;
            else if ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) begin//If next space is occupied by black piece.
              if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                isCheck[3] = 1'b1;
                isCheckDir[6] = 1'b1;
              end	
              else if((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                isCheck[2] = 1'b1;
                isCheckDir[6] = 1'b1;
              end	
              else if ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_001)begin//Queen 
                isCheck[1] = 1'b1; 
                isCheckDir[6] = 1'b1;
              end	
              else if (((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]+j] & 6'b001_111) <= 6'b001_111) && ((board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]-j] & 6'b001_111) >= 6'b000_111))begin//Pawn 
                isCheck[board[tempLVW[5 -: 3]+j][tempLVW[5-3 -:3]+j][3:0]] = 1'b1; 
                isCheckDir[6] = 1'b1;
              end	
              king_flag = 0; //Break;
            end
          end
        end
        king_flag = 1;


        for(j = 1; j < 8; j = j +1) begin //Lower Left
          if(tempLVW[5 -:3] != 0 && tempLVW[5-3 -:3] != 0)begin
            if ((tempLVW[5 -:3] - j > 0) && (tempLVW[5-3 -:3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag = 0;
              else if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) begin //If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                  isCheck[3] = 1'b1;
                  isCheckDir[2] = 1'b1;
                end	
                else if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                  isCheck[2] = 1'b1;
                  isCheckDir[2] = 1'b1;
                end	
                else if ((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1; 
                  isCheckDir[2] = 1'b1;
                end	
                king_flag  = 0; //Break;
              end
            end
            else if(((tempLVW[5 -:3] - j == 0) || (tempLVW[5-3 -:3] - j == 0))&& king_flag == 1) begin
              if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag  = 0; //Break;
              else if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) begin //If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                  isCheck[3] = 1'b1;
                  isCheckDir[2] = 1'b1;
                end	
                else if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                  isCheck[2] = 1'b1;
                  isCheckDir[2] = 1'b1;
                end	
                else if ((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1; 
                  isCheckDir[2] = 1'b1;
                end	
                king_flag  = 0; //Break;
              end
              king_flag = 0; //Break;
            end
            else
              king_flag = 0;
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j + 1) begin //Lower Right
          if(tempLVW[5 -:3] != 0)begin
            if ((tempLVW[5 -:3] - j < 8) && (tempLVW[5-3 -:3] + j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) begin//If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                  isCheck[3] = 1'b1;
                  isCheckDir[4] = 1'b1;
                end	
                else if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                  isCheck[2] = 1'b1;
                  isCheckDir[4] = 1'b1;
                end	
                else if ((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1; 
                  isCheckDir[4] = 1'b1;
                end	
                king_flag  = 0; //Break;
              end
            end
            else if((tempLVW[5 -:3] - j == 0)&& king_flag == 1) begin
              if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) //If next space is white and occupied.
                king_flag  = 0; //Break;
              else if ((board[tempLVW[5 -: 3] - j][tempLVW[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) begin//If next space is occupied by black piece.
                if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_011)begin//Bishop 1 
                  isCheck[3] = 1'b1;
                  isCheckDir[4] = 1'b1;
                end
                else if((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_010)begin//Bishop 2  
                  isCheck[2] = 1'b1;
                  isCheckDir[4] = 1'b1;
                end
                else if ((board[tempLVW[5 -: 3]-j][tempLVW[5-3 -:3]+j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1; 	
                  isCheckDir[4] = 1'b1;
                end
                king_flag  = 0; //Break;
              end
            end
            else
              king_flag = 0;
          end
        end
        king_flag = 1;

        // Up: 2 Left: 1
        if (((tempLVW[5 -: 3] + 2) < 8) && ((tempLVW[2 -: 3]) > 0))begin
          if ((board[tempLVW[5 -: 3] + 2][tempLVW[2 -: 3] - 1] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5 -: 3] + 2][tempLVW[2 -: 3] - 1] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Up: 1 Left: 2
        if (((tempLVW[5 -: 3] + 1) < 8) && ((tempLVW[2 -: 3]) > 1))begin
          if ((board[tempLVW[5-: 3] + 1][tempLVW[2 -: 3] - 2] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5-: 3] + 1][tempLVW[2 -: 3] - 2] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Up: 2 Right: 1
        if (((tempLVW[5 -: 3] + 2) < 8) && ((tempLVW[2 -: 3] + 1) < 8))begin
          if ((board[tempLVW[5 -: 3] + 2][tempLVW[2 -: 3] + 1] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5 -: 3] + 2][tempLVW[2 -: 3] + 1] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Up: 1 Right: 2
        if (((tempLVW[5 -: 3] + 1) < 8) && ((tempLVW[2 -: 3] + 2) < 8))begin
          if ((board[tempLVW[5 -: 3] + 1][tempLVW[2 -: 3] + 2] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5 -: 3] + 1][tempLVW[2 -: 3] + 2] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 2 Left: 1
        if (((tempLVW[5-: 3]) > 1) && ((tempLVW[2 -: 3]) > 0))begin
          if ((board[tempLVW[5-: 3] - 2][tempLVW[2 -: 3] - 1] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5-: 3] - 2][tempLVW[2 -: 3] - 1] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 1 Left: 2
        if (((tempLVW[5-: 3]) > 0) && ((tempLVW[2 -: 3]) > 1))begin
          if ((board[tempLVW[5-: 3] - 1][tempLVW[2 -: 3] - 2] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5-: 3] - 1][tempLVW[2 -: 3] - 2] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 2 Right: 1
        if (((tempLVW[5-: 3]) > 1) && ((tempLVW[2 -: 3] + 1) < 8))begin
          if ((board[tempLVW[5-: 3] - 2][tempLVW[2 -: 3] + 1] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5-: 3] - 2][tempLVW[2 -: 3] + 1] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 1 Right: 2
        if (((tempLVW[5-: 3]) > 0) && ((tempLVW[2 -: 3] + 2) < 8))begin
          if ((board[tempLVW[5 -: 3] - 1][tempLVW[2 -: 3] + 2] & 6'b111111) == 6'b100101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVW[5 -: 3] - 1][tempLVW[2 -: 3] + 2] & 6'b111111) == 6'b100100)begin
            isCheck[4] = 1'b1;
          end
        end
      end // White End

      else begin 
        for(j = 1; j < 8; j = j + 1) begin //Left
          if(tempLVB[2 :0] != 0)begin
            if ((tempLVB[5 :3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b100_000)begin //If next space is occupied by White piece.
                king_flag  = 0; //Break;
              end
              else if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b110_000)begin //If next space is occupied by Black piece.
                if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b001_111) == 6'b000_111)//Rook 1 
                  isCheck[7] = 1'b1;
                else if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b001_111) == 6'b000_110)//Rook 2  
                  isCheck[6] = 1'b1;
                else if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b001_111) == 6'b000_001)begin//Queen 
                  isCheck[1] = 1'b1;
                end
                king_flag  = 0; //Break;
              end
            end
            else if((tempLVB[5-3 -:3] == j)&& king_flag == 1) begin
              if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) //If next space is occupied by White piece.
                king_flag  = 0; //Break;
              else if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b110_000)begin //If next space is occupied by Black piece.
                if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b001_111) == 6'b000_111)//Rook 1 
                  isCheck[7] = 1'b1;
                else if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b001_111) == 6'b000_110)//Rook 2  
                  isCheck[6] = 1'b1;
                else if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] - j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1;
              end
              king_flag = 0; //Break;

            end
          end
        end
        king_flag = 1;
        // End of Left  


        for(j = 1; j < 8; j = j + 1) begin //Right
          if (tempLVB[5-3 -:3] + j < 8 && king_flag == 1) begin // If still on board.
            if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) //If next space is white.
              king_flag = 0; //Break;
            else if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) begin//If next space is occupied by black piece.
              if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] + j] & 6'b001_111) == 6'b000_111)//Rook 1 
                isCheck[7] = 1'b1;
              else if((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] + j] & 6'b001_111) == 6'b000_110)//Rook 2  
                isCheck[6] = 1'b1;
              else if ((board[tempLVB[5 -: 3]][tempLVB[5-3 -:3] + j] & 6'b001_111) == 6'b000_001)//Queen 
                isCheck[1] = 1'b1;
              king_flag = 0; //Break;
            end
          end
        end
        king_flag = 1;


        for(j = 1; j < 8; j = j +1) begin //Up
          if (tempLVB[5 -:3] + j < 8 && king_flag == 1) begin // If still on board.
            if ((board[tempLVB[5 -: 3] + j][tempLVB[5-3 -:3]] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
              king_flag = 0; //Break;
            else if ((board[tempLVB[5 -: 3] + j][tempLVB[5-3 -:3]] & 6'b110_000) == 6'b110_000) begin //If next space is occupied by black piece.
              if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_111)//Rook 1 
                isCheck[7] = 1'b1;
              else if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_110)//Rook 2  
                isCheck[6] = 1'b1;
              else if ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_001)//Queen 
                isCheck[1] = 1'b1;    
              king_flag = 0; //Break;
            end
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j +1) begin //Down
          if(tempLVB[5 -:3] != 0)begin
            if ((tempLVB[5 -:3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3]] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3]] & 6'b110_000) == 6'b110_000)begin //If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_111)//Rook 1 
                  isCheck[7] = 1'b1;
                else if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_110)//Rook 2  
                  isCheck[6] = 1'b1;
                else if ((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1;              
                king_flag = 0; //Break;
              end
            end
            else if((tempLVB[5 -:3] - j == 0)&& king_flag == 1) begin
              if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3]] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3]] & 6'b110_000) == 6'b110_000)begin //If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_111)//Rook 1 
                  isCheck[7] = 1'b1;
                else if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_110)//Rook 2  
                  isCheck[6] = 1'b1;
                else if ((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1;              
                king_flag = 0; //Break;
              end
            end
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j + 1) begin //Upper Left
          if(tempLVB[5-3 -:3] != 0)begin
            if ((tempLVB[5 -:3] + j < 8) && (tempLVB[5-3 -:3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVB[5 -: 3] + j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVB[5 -: 3] + j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) begin//If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                  isCheck[3] = 1'b1;
                else if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                  isCheck[2] = 1'b1;
                else if ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1; 
                else if (((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) <= 6'b001_111) && ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) >= 6'b000_111))//Pawn 
                  isCheck[board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j][3:0]] = 1'b1; 
                king_flag  = 0; //Break;
              end
            end
            else if((tempLVB[5-3 -:3] - j == 0)&& king_flag == 1) begin
              if ((board[tempLVB[5 -: 3] + j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag  = 0; //Break;
              else if ((board[tempLVB[5 -: 3] + j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) begin//If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                  isCheck[3] = 1'b1;
                else if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                  isCheck[2] = 1'b1;
                else if ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1;
                else if (((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) <= 6'b001_111) && ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) >= 6'b000_111))//Pawn 
                  isCheck[board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j][3:0]] = 1'b1; 		
                king_flag  = 0; //Break;
              end
            end
            else
              king_flag = 0;
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j + 1) begin //Upper Right
          if ((tempLVB[5 -:3] + j < 8) &&(tempLVB[5-3 -:3] + j < 8) && king_flag == 1) begin // If still on board.
            if ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
              king_flag  = 0; //Break;
            else if ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) begin//If next space is occupied by black piece.
              if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                isCheck[3] = 1'b1;
              else if((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                isCheck[2] = 1'b1;
              else if ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_001)//Queen 
                isCheck[1] = 1'b1; 
              else if (((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]+j] & 6'b001_111) <= 6'b001_111) && ((board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]-j] & 6'b001_111) >= 6'b000_111))//Pawn 
                isCheck[board[tempLVB[5 -: 3]+j][tempLVB[5-3 -:3]+j][3:0]] = 1'b1; 
              king_flag = 0; //Break;
            end
          end
        end
        king_flag = 1;


        for(j = 1; j < 8; j = j +1) begin //Lower Left
          if(tempLVB[5 -:3] != 0 && tempLVB[5-3 -:3] != 0)begin
            if ((tempLVB[5 -:3] - j > 0) && (tempLVB[5-3 -:3] - j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag = 0;
              else if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) begin //If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                  isCheck[3] = 1'b1;
                else if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                  isCheck[2] = 1'b1;
                else if ((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1; 
                king_flag  = 0; //Break;
              end
            end
            else if(((tempLVB[5 -:3] - j == 0) || (tempLVB[5-3 -:3] - j == 0))&& king_flag == 1) begin
              if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag  = 0; //Break;
              else if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] - j] & 6'b110_000) == 6'b110_000) begin //If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                  isCheck[3] = 1'b1;
                else if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                  isCheck[2] = 1'b1;
                else if ((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]-j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1; 
                king_flag  = 0; //Break;
              end
              king_flag = 0; //Break;
            end
            else
              king_flag = 0;
          end
        end
        king_flag = 1;

        for(j = 1; j < 8; j = j + 1) begin //Lower Right
          if(tempLVB[5 -:3] != 0)begin
            if ((tempLVB[5 -:3] - j < 8) && (tempLVB[5-3 -:3] + j > 0) && king_flag == 1) begin // If still on board.
              if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag = 0; //Break;
              else if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) begin//If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                  isCheck[3] = 1'b1;
                else if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                  isCheck[2] = 1'b1;
                else if ((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1; 
                king_flag  = 0; //Break;
              end
            end
            else if((tempLVB[5 -:3] - j == 0)&& king_flag == 1) begin
              if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b100_000) //If next space is white and occupied.
                king_flag  = 0; //Break;
              else if ((board[tempLVB[5 -: 3] - j][tempLVB[5-3 -:3] + j] & 6'b110_000) == 6'b110_000) begin//If next space is occupied by black piece.
                if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_011)//Bishop 1 
                  isCheck[3] = 1'b1;
                else if((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_010)//Bishop 2  
                  isCheck[2] = 1'b1;
                else if ((board[tempLVB[5 -: 3]-j][tempLVB[5-3 -:3]+j] & 6'b001_111) == 6'b000_001)//Queen 
                  isCheck[1] = 1'b1; 	
                king_flag  = 0; //Break;
              end
            end
            else
              king_flag = 0;
          end
        end
        king_flag = 1;
        // Up: 2 Left: 1
        if (((tempLVB[5 -: 3] + 2) < 8) && ((tempLVB[2 -: 3]) > 0))begin
          if ((board[tempLVB[5 -: 3] + 2][tempLVB[2 -: 3] - 1] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] + 2][tempLVB[2 -: 3] - 1] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Up: 1 Left: 2
        if (((tempLVB[5 -: 3] + 1) < 8) && ((tempLVB[2 -: 3]) > 1))begin
          if ((board[tempLVB[5 -: 3] + 1][tempLVB[2 -: 3] - 2] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] + 1][tempLVB[2 -: 3] - 2] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Up: 2 Right: 1
        if (((tempLVB[5 -: 3] + 2) < 8) && ((tempLVB[2 -: 3] + 1) < 8))begin
          if ((board[tempLVB[5 -: 3] + 2][tempLVB[2 -: 3] + 1] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] + 2][tempLVB[2 -: 3] + 1] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Up: 1 Right: 2
        if (((tempLVB[5 -: 3] + 1) < 8) && ((tempLVB[2 -: 3] + 2) < 8))begin
          if ((board[tempLVB[5 -: 3] + 1][tempLVB[2 -: 3] + 2] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] + 1][tempLVB[2 -: 3] + 2] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 2 Left: 1
        if (((tempLVB[5 -: 3]) > 1) && ((tempLVB[2 -: 3]) > 0))begin
          if ((board[tempLVB[5 -: 3] - 2][tempLVB[2 -: 3] - 1] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] - 2][tempLVB[2 -: 3] - 1] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 1 Left: 2
        if (((tempLVB[5 -: 3]) > 0) && ((tempLVB[2 -: 3]) > 1))begin
          if ((board[tempLVB[5 -: 3] - 1][tempLVB[2 -: 3] - 2] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] - 1][tempLVB[2 -: 3] - 2] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 2 Right: 1
        if (((tempLVB[5 -: 3]) > 1) && ((tempLVB[2 -: 3] + 1) < 8))begin
          if ((board[tempLVB[5 -: 3] - 2][tempLVB[2 -: 3] + 1] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5 -: 3] - 2][tempLVB[2 -: 3] + 1] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
        // Down: 1 Right: 2
        if (((tempLVB[5 -: 3]) > 0) && ((tempLVB[2 -: 3] + 2) < 8))begin
          if ((board[tempLVB[5-: 3] - 1][tempLVB[2 -: 3] + 2] & 6'b111111) == 6'b110101)begin
            isCheck[5] = 1'b1;
          end
          if ((board[tempLVB[5-: 3] - 1][tempLVB[2 -: 3] + 2] & 6'b111111) == 6'b110100)begin
            isCheck[4] = 1'b1;
          end
        end
      end
    end

endmodule