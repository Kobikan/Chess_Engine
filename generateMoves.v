module generateMoves(clock,
                     reset,
                     enable,
                     player,
                     locationVectorWhite,
                     locationVectorBlack,
                     aliveVectorWhite,
                     aliveVectorBlack,
                     moveSet);
    input clock;
    input reset;
    input enable;
    input player;
    input [95: 0]locationVectorWhite;
    input [95: 0]locationVectorBlack;
    input [15: 0]aliveVectorWhite;
    input [15: 0]aliveVectorBlack;
    output reg [127: 0]moveSet;
    
    wire clock;
    wire reset;
    wire enable;
    
    reg [3:0] pawn;
    reg [11:0]rook;
    reg [7:0]knight;
    reg [11:0]bishop;
    reg [7:0]king;
    
    wire [95: 0] tempLVW, tempLVB;
    wire [15: 0] tempAVW, tempAVB;
    
    reg[5:0] board [7:0][7:0]; // Occupied, Black or White, Piece ID
    parameter BLACK    = 1'b0;
    parameter WHITE    = 1'b1;
    parameter P1       = 4'b1111;
    parameter P2       = 4'b1110;
    parameter P3       = 4'b1101;
    parameter P4       = 4'b1100;
    parameter P5       = 4'b1011;
    parameter P6       = 4'b1010;
    parameter P7       = 4'b1001;
    parameter P8       = 4'b1000;
    parameter R1       = 4'b0111;
    parameter R2       = 4'b0110;
    parameter N1       = 4'b0101;
    parameter N2       = 4'b0100;
    parameter B1       = 4'b0011;
    parameter B2       = 4'b0010;
    parameter Q1       = 4'b0001;
    parameter K1       = 4'b0000;
    parameter occupied = 1'b1;
    parameter empty    = 1'b0;
    
    integer i, j, k, local_p, pawnCounter = 0, rookCounter = 0, rook_flag = 1, knightCounter = 0, bishopCounter = 0, bishop_flag = 1;
    
    initial begin
        pawn   = 1'h0;
        rook   = 12'h000;
        knight = 2'h00;
        bishop = 12'h000;
        king   = 2'h00;
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
        
        
        //Board Game Logic
        // White = 1; Black = 0
        pawnCounter <= 0;
        for(i = 95; i > 47; i = i-6) begin
            if (local_p == 1) begin
                if (tempAVW[i/6]) begin
                    if ((board[tempLVW[i-: 3]+ local_p][tempLVW[i-3 -: 3]] && 6'b100000) == 6'b000000) begin
                        pawn[3] <= 1'b1;
                        if (((board[tempLVW[i -: 3] +(local_p * 2)][tempLVW[i-3 -: 3]] && 6'b100000) == 6'b000000)&& (tempLVW[i -: 3] == 3'b001))
                            pawn[2] <= 1'b1;
                        else
                            pawn[2] <= 1'b0;
                    end
                    else
                        pawn[3:2] <= 2'b00;
                        // Upper Left occupied
                        if (tempLVW[i-3 -: 3] -1 >= 0) begin
                            if ((board[tempLVW[i -: 3]+ local_p][tempLVW[i-3 -: 3] -1] && 6'b110_000) == 6'b110_000)
                                pawn[1] <= 1'b1;
                            else
                                pawn[1] <= 1'b0;
                        end
                    
                    if (tempLVW[i-3 -: 3] +1 < 8) begin
                        if ((board[tempLVW[i -: 3]+ local_p][tempLVW[i-3 -: 3] +1] && 6'b110_000) == 6'b110_000)
                            pawn[0] <= 1'b1;
                        else
                            pawn[0] <= 1'b0;
                    end
                end
            end
            else begin
                if (tempAVB[i/6]) begin
                    if ((board[tempLVB[i -: 3]+ local_p][tempLVB[i-3 -: 3]] && 6'b100000) == 6'b000000) begin
                        pawn[3] <= 1'b1;
                        if (((board[tempLVB[i -: 3] +(local_p * 2)][tempLVB[i-3 -: 3]] && 6'b100000) == 6'b000000)&& (tempLVB[i -: 3] == 3'b001))
                            pawn[2] <= 1'b1;
                        else
                            pawn[2] <= 1'b0;
                    end
                    else
                        pawn[3:2] <= 2'b00;
                    
                    // Upper Left occupied
                    if (tempLVB[i-3 -: 3] -1 >= 0) begin
                        if ((board[tempLVB[i -: 3]+ local_p][tempLVB[i-3 -: 3] -1] && 6'b110_000) == 6'b110_000)
                            pawn[1] <= 1'b1;
                        else
                            pawn[1] <= 1'b0;
                    end
                    
                    if (tempLVB[i-3 -: 3] +1 < 8) begin
                        if ((board[tempLVB[i -: 3]+ local_p][tempLVB[i-3 -: 3] +1] && 6'b110_000) == 6'b110_000)
                            pawn[0] <= 1'b1;
                        else
                            pawn[0] <= 1'b0;
                    end
                end
            end
            moveSet[127-(4*pawnCounter) -: 4] = pawn;
            pawnCounter <= pawnCounter + 1;
            pawn        <= 4'b0000;
        end
        
        
        
        //Rook
        rook_flag   <= 1;
        rookCounter <= 0;
        for(i = 47; i > 35; i = i-6) begin
            if (local_p == 1) begin
                if (tempAVW[i/6]) begin
                    for(j = 1; j < 8; j = j + 1) begin //Left
                        if (tempLVW[i-3 -:3] - j > 0 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[11:9] <= rook[11:9] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] - j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                    rook[11:9] <= rook[11:9] + 3'b001;
                                    rook_flag  <= 0; //Break;
                                end
                            end
                        end
                    end
                    rook_flag <= 1;
                    
                    for(j = 1; j < 8; j = j + 1) begin //Right
                        if (tempLVW[i-3 -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] + j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[8:6] <= rook[8:6] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3]][tempLVW[i-3 -:3] + j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                    rook[8:6] <= rook[8:6] + 3'b001;
                                    rook_flag <= 0; //Break;
                                end
                            end
                        end
                    end
                    rook_flag <= 1;
                    
                    
                    for(j = 1; j < 8; j = j +1) begin //Up
                        if (tempLVW[i -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3]] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[5:3] <= rook[5:3] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3]] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                    rook[5:3] <= rook[5:3] + 3'b001;
                                    rook_flag <= 0; //Break;
                                end
                            end
                        end
                    end
                    rook_flag <= 1;
                    
                    for(j = 1; j < 8; j = j +1) begin //Down
                        if (tempLVW[i -:3] - j > 0 && rook_flag == 1) begin // If still on board.
                            if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                                rook[2:0] <= rook[2:0] + 3'b001;
                            else begin
                                if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3]] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                    rook[2:0] <= rook[2:0] + 3'b001;
                                    rook_flag <= 0; //Break;
                                end
                            end
                        end
                    end
                    rook_flag <= 1;
                end // Alive Vector End
            end // Player End
            
            //Black
            else begin
            if (tempAVB[i/6]) begin
                for(j = 1; j < 8; j = j + 1) begin //Left
                    if (tempLVB[i-3 -:3] - j >= 0 && rook_flag == 1) begin // If still on board.
                        if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            rook[11:9] <= rook[11:9] + 3'b001;
                        else begin
                            if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] - j] && 6'b010_000) != 6'b000_000)begin //If next space is occupied by white piece.
                                rook[11:9] <= rook[11:9] + 3'b001;
                                rook_flag  <= 0; //Break;
                            end
                        end
                    end
                end
                rook_flag <= 1;
                
                for(j = 1; j < 8; j = j + 1) begin //Right
                    if (tempLVB[i-3 -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                        if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] + j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            rook[8:6] <= rook[8:6] + 3'b001;
                        else begin
                            if ((board[tempLVB[i -: 3]][tempLVB[i-3 -:3] + j] && 6'b010_000) != 6'b000_000)begin //If next space is occupied by white piece.
                                rook[8:6] <= rook[8:6] + 3'b001;
                                rook_flag <= 0; //Break;
                            end
                        end
                    end
                end
                rook_flag <= 1;
                
                
                for(j = 1; j < 8; j = j +1) begin //Up
                    if (tempLVB[i -:3] + j < 8 && rook_flag == 1) begin // If still on board.
                        if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3]] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            rook[5:3] <= rook[5:3] + 3'b001;
                        else begin
                            if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3]] && 6'b010_000) != 6'b000_000)begin //If next space is occupied by white piece.
                                rook[5:3] <= rook[5:3] + 3'b001;
                                rook_flag <= 0; //Break;
                            end
                        end
                    end
                end
                rook_flag <= 1;
                
                for(j = 1; j < 8; j = j +1) begin //Down
                    if (tempLVB[i -:3] - j >= 0 && rook_flag == 1) begin // If still on board.
                        if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            rook[2:0] <= rook[2:0] + 3'b001;
                        else begin
                            if ((board[tempLVB[i -: 3] - j][tempLVB[i-3 -:3]] && 6'b010_000) != 6'b000_000)begin //If next space is occupied by white piece.
                                rook[2:0] <= rook[2:0] + 3'b001;
                                rook_flag <= 0; //Break;
                            end
                        end
                    end
                end
                rook_flag <= 1;
            end
        end
        moveSet[95 - (rookCounter*12) -: 12] <= rook;
        rook                                 <= 12'b0000_0000_0000;
        rookCounter                          <= rookCounter + 1;
    end
    
    // Knight
    for(i = 35; i > 23; i = i-6) begin
        if (local_p == 1) begin
            if (tempAVW[i/6]) begin
                // Up: 2 Left: 1
                if (((tempLVW[i-: 3] + 2) < 8) && ((tempLVW[i-3 -: 3] - 1) >= 0))begin
                    if ((board[tempLVW[i-: 3] + 2][tempLVW[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        knight[7] <= 1'b1;
                    end
                end
                // Up: 1 Left: 2
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3] - 2) >= 0))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] - 2] && 6'b010000) != 6'b010000)begin
                        knight[6] <= 1'b1;
                    end
                end
                // Up: 2 Right: 1
                if (((tempLVW[i-: 3] + 2) < 8) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] + 2][tempLVW[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        knight[5] <= 1'b1;
                    end
                end
                // Up: 1 Right: 2
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] + 2] && 6'b010000) != 6'b010000)begin
                        knight[4] <= 1'b1;
                    end
                end
                // Down: 2 Left: 1
                if (((tempLVW[i-: 3] + 2) >= 0) && ((tempLVW[i-3 -: 3] - 1) >= 0))begin
                    if ((board[tempLVW[i-: 3] - 2][tempLVW[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        knight[3] <= 1'b1;
                    end
                end
                // Down: 1 Left: 2
                if (((tempLVW[i-: 3] + 1) >= 0) && ((tempLVW[i-3 -: 3] - 2) >= 0))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] - 2] && 6'b010000) != 6'b010000)begin
                        knight[2] <= 1'b1;
                    end
                end
                // Down: 2 Right: 1
                if (((tempLVW[i-: 3] - 2) >= 0) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] - 2][tempLVW[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        knight[1] <= 1'b1;
                    end
                end
                // Down: 1 Right: 2
                if (((tempLVW[i-: 3] - 1) >= 0) && ((tempLVW[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] + 2] && 6'b010000) != 6'b010000)begin
                        knight[0] <= 1'b1;
                    end
                end
            end
        end
        else begin
            if (tempAVB[i/6]) begin
                // Up: 2 Left: 1
                if (((tempLVB[i-: 3] + 2) < 8) && ((tempLVB[i-3 -: 3] - 1) >= 0))begin
                    if ((board[tempLVB[i-: 3] + 2][tempLVB[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        knight[7] <= 1'b1;
                    end
                end
                // Up: 1 Left: 2
                if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3] - 2) >= 0))begin
                    if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] - 2] && 6'b010000) != 6'b010000)begin
                        knight[6] <= 1'b1;
                    end
                end
                // Up: 2 Right: 1
                if (((tempLVB[i-: 3] + 2) < 8) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVB[i-: 3] + 2][tempLVB[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        knight[5] <= 1'b1;
                    end
                end
                // Up: 1 Right: 2
                if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] + 2] && 6'b010000) != 6'b010000)begin
                        knight[4] <= 1'b1;
                    end
                end
                // Down: 2 Left: 1
                if (((tempLVB[i-: 3] + 2) >= 0) && ((tempLVB[i-3 -: 3] - 1) >= 0))begin
                    if ((board[tempLVB[i-: 3] - 2][tempLVB[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        knight[3] <= 1'b1;
                    end
                end
                // Down: 1 Left: 2
                if (((tempLVB[i-: 3] + 1) >= 0) && ((tempLVB[i-3 -: 3] - 2) >= 0))begin
                    if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] - 2] && 6'b010000) != 6'b010000)begin
                        knight[2] <= 1'b1;
                    end
                end
                // Down: 2 Right: 1
                if (((tempLVB[i-: 3] - 2) >= 0) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVB[i-: 3] - 2][tempLVB[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        knight[1] <= 1'b1;
                    end
                end
                // Down: 1 Right: 2
                if (((tempLVB[i-: 3] - 1) >= 0) && ((tempLVB[i-3 -: 3] + 2) < 8))begin
                    if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] + 2] && 6'b010000) != 6'b010000)begin
                        knight[0] <= 1'b1;
                    end
                end
            end
        end
        moveSet[71-(8*knightCounter) -: 8] = knight;
        knightCounter <= knightCounter + 1;
        knight        <= 2'h00;
    end
    
    
    
    //Bishop
    bishop_flag   <= 1;
    bishopCounter <= 0;
    for(i = 23; i > 11; i = i-6) begin
        if (local_p == 1) begin
            if (tempAVW[i/6]) begin
                for(j = 1; j < 8; j = j + 1) begin //Upper Left
                    if (tempLVW[i -:3] + j < 8 && tempLVW[i-3 -:3] - j >= 0 && bishop_flag == 1) begin // If still on board.
                        if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            bishop[11:9] <= bishop[11:9] + 3'b001;
                        else begin
                            if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] - j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                bishop[11:9] <= bishop[11:9] + 3'b001;
                                bishop_flag  <= 0; //Break;
                            end
                        end
                    end
                end
                bishop_flag <= 1;
                
                for(j = 1; j < 8; j = j + 1) begin //Upper Right
                    if (tempLVW[i -:3] + j < 8 && tempLVW[i-3 -:3] + j < 8 && bishop_flag == 1) begin // If still on board.
                        if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] + j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            bishop[8:6] <= bishop[8:6] + 3'b001;
                        else begin
                            if ((board[tempLVW[i -: 3] + j][tempLVW[i-3 -:3] + j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                bishop[8:6] <= bishop[8:6] + 3'b001;
                                bishop_flag <= 0; //Break;
                            end
                        end
                    end
                end
                bishop_flag <= 1;
                
                
                for(j = 1; j < 8; j = j +1) begin //Lower Left
                    if (tempLVW[i -:3] - j >= 0 && tempLVW[i-3 -:3] - j >= 0 && bishop_flag == 1) begin // If still on board.
                        if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            bishop[5:3] <= bishop[5:3] + 3'b001;
                        else begin
                            if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                bishop[5:3] <= bishop[5:3] + 3'b001;
                                bishop_flag <= 0; //Break;
                            end
                        end
                    end
                end
                bishop_flag <= 1;
                
                for(j = 1; j < 8; j = j +1) begin //Lower Right
                    if (tempLVW[i -:3] - j >= 0 && tempLVW[i-3 -:3] + j < 8 && bishop_flag == 1) begin // If still on board.
                        if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 +:3] + j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                            bishop[2:0] <= bishop[2:0] + 3'b001;
                        else begin
                            if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                                bishop[2:0] <= bishop[2:0] + 3'b001;
                                bishop_flag <= 0; //Break;
                            end
                        end
                    end
                end
                bishop_flag <= 1;
            end // Alive Vector End
        end // Player End
        
        //Black
        else begin
        if (tempAVB[i/6]) begin
            for(j = 1; j < 8; j = j + 1) begin //Upper Left
                if (tempLVB[i -:3] + j < 8 && tempLVB[i-3 -:3] - j >= 0 && bishop_flag == 1) begin // If still on board.
                    if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                        bishop[11:9] <= bishop[11:9] + 3'b001;
                    else begin
                        if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] - j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                            bishop[11:9] <= bishop[11:9] + 3'b001;
                            bishop_flag  <= 0; //Break;
                        end
                    end
                end
            end
            bishop_flag <= 1;
            
            for(j = 1; j < 8; j = j + 1) begin //Upper Right
                if (tempLVB[i -:3] + j < 8 && tempLVB[i-3 -:3] + j < 8 && bishop_flag == 1) begin // If still on board.
                    if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] + j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                        bishop[8:6] <= bishop[8:6] + 3'b001;
                    else begin
                        if ((board[tempLVB[i -: 3] + j][tempLVB[i-3 -:3] + j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                            bishop[8:6] <= bishop[8:6] + 3'b001;
                            bishop_flag <= 0; //Break;
                        end
                    end
                end
            end
            bishop_flag <= 1;
            
            
            for(j = 1; j < 8; j = j +1) begin //Lower Left
                if (tempLVW[i -:3] - j >= 0 && tempLVW[i-3 -:3] - j >= 0 && bishop_flag == 1) begin // If still on board.
                    if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                        bishop[5:3] <= bishop[5:3] + 3'b001;
                    else begin
                        if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] - j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                            bishop[5:3] <= bishop[5:3] + 3'b001;
                            bishop_flag <= 0; //Break;
                        end
                    end
                end
            end
            bishop_flag <= 1;
            
            for(j = 1; j < 8; j = j +1) begin //Lower Right
                if (tempLVW[i -:3] - j >= 0 && tempLVW[i-3 -:3] + j < 8 && bishop_flag == 1) begin // If still on board.
                    if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 +:3] + j] && 6'b100_000) == 6'b000_000) //If next space is not occupied.
                        bishop[2:0] <= bishop[2:0] + 3'b001;
                    else begin
                        if ((board[tempLVW[i -: 3] - j][tempLVW[i-3 -:3] + j] && 6'b010_000) != 6'b010_000)begin //If next space is occupied by black piece.
                            bishop[2:0] <= bishop[2:0] + 3'b001;
                            bishop_flag <= 0; //Break;
                        end
                    end
                end
            end
            bishop_flag <= 1;
        end // Alive Vector End
    end
    moveSet[54 - (bishopCounter*12) -: 12] <= bishop;
    bishop                                 <= 12'b0000_0000_0000;
    bishopCounter                          <= bishopCounter + 1;
    end
    
    // King
    for(i = 5; i > 0; i = i-6) begin
        if (local_p == 1) begin
            if (tempAVW[i/6]) begin
                // Upper Left
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3] - 1) >= 0))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        king[7] <= 1'b1;
                    end
                end
                // Up
                if ((tempLVW[i-: 3] + 1) < 8)begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3]] && 6'b010000) != 6'b010000)begin
                        king[6] <= 1'b1;
                    end
                end
                // Upper Right
                if (((tempLVW[i-: 3] + 1) < 8) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] + 1][tempLVW[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        king[5] <= 1'b1;
                    end
                end
                // Right
                if ((tempLVW[i-3 -: 3] + 1) < 8)begin
                    if ((board[tempLVW[i-: 3]][tempLVW[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        king[4] <= 1'b1;
                    end
                end
                // Lower Right
                if (((tempLVW[i-: 3] - 1) >= 0) && ((tempLVW[i-3 -: 3] + 1) < 8))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] + 1] && 6'b010000) != 6'b010000)begin
                        king[3] <= 1'b1;
                    end
                end
                // Down
                if ((tempLVW[i-: 3] - 1) >= 0) begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3]] && 6'b010000) != 6'b010000)begin
                        king[2] <= 1'b1;
                    end
                end
                // Lower Left
                if (((tempLVW[i-: 3] - 1) >= 0) && ((tempLVW[i-3 -: 3] - 1) >= 0))begin
                    if ((board[tempLVW[i-: 3] - 1][tempLVW[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        king[1] <= 1'b1;
                    end
                end
                // Left
                if ((tempLVW[i-3 -: 3] - 1) >= 0)begin
                    if ((board[tempLVW[i-: 3]][tempLVW[i-3 -: 3] - 1] && 6'b010000) != 6'b010000)begin
                        king[0] <= 1'b1;
                    end
                end
				end
         end
         else begin
				 if (tempAVB[i/6]) begin
					  // Upper Left
					  if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3] - 1) >= 0))begin
							if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] - 1] && 6'b010000) != 6'b000000)begin
								 king[7] <= 1'b1;
							end
					  end
					  // Up
					  if ((tempLVB[i-: 3] + 1) < 8)begin
							if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3]] && 6'b010000) != 6'b000000)begin
								 king[6] <= 1'b1;
							end
					  end
					  // Upper Right
					  if (((tempLVB[i-: 3] + 1) < 8) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
							if ((board[tempLVB[i-: 3] + 1][tempLVB[i-3 -: 3] + 1] && 6'b010000) != 6'b000000)begin
								 king[5] <= 1'b1;
							end
					  end
					  // Right
					  if ((tempLVB[i-3 -: 3] + 1) < 8)begin
							if ((board[tempLVB[i-: 3]][tempLVB[i-3 -: 3] + 1] && 6'b010000) != 6'b000000)begin
								 king[4] <= 1'b1;
							end
					  end
					  // Lower Right
					  if (((tempLVB[i-: 3] - 1) >= 0) && ((tempLVB[i-3 -: 3] + 1) < 8))begin
							if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] + 1] && 6'b010000) != 6'b000000)begin
								 king[3] <= 1'b1;
							end
					  end
					  // Down
					  if ((tempLVB[i-: 3] - 1) >= 0)begin
							if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3]] && 6'b010000) != 6'b000000)begin
								 king[2] <= 1'b1;
							end
					  end
					  // Lower Left
					  if (((tempLVB[i-: 3] - 1) >= 0) && ((tempLVB[i-3 -: 3] - 1) >= 0))begin
							if ((board[tempLVB[i-: 3] - 1][tempLVB[i-3 -: 3] - 1] && 6'b010000) != 6'b000000)begin
								 king[1] <= 1'b1;
							end
					  end
					  // Left
					  if ((tempLVB[i-3 -: 3] - 1) >= 0)begin
							if ((board[tempLVB[i-: 3]][tempLVB[i-3 -: 3] - 1] && 6'b010000) != 6'b000000)begin
								 king[0] <= 1'b1;
							end
					  end
                end
            end
            moveSet[7 -: 8] = king;
            king <= 2'h00;
        end
    end // Always Block End
endmodule
