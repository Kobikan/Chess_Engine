REMEMBER TO ADD THIS TO TOP:
isCheck = 4'h0000; 

// Knight Code ------ Copy into section without for loop.
      
        if (local_p == 1) begin
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
        end
        else begin
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
		  knight_flag=1;