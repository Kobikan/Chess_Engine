module board_update_v (clk, RST, en, player, move_input, piece_number, location_vectors_w, location_vectors_b, alive_vectors_w, alive_vectors_b, dbg_state, output_player, done);
	input clk;
	input RST;
	input player;
	input en;
	input [5:0] move_input;
	input [3:0] piece_number;
	output [95:0] location_vectors_w;
	output [95:0] location_vectors_b;
	output [15:0] alive_vectors_w;
	output [15:0] alive_vectors_b;
	output dbg_state;
	output output_player;
	output done;
	
	reg [5:0] move_input_q;
	reg [5:0] move_input_d;
	reg [3:0] piece_number_q;
	reg [3:0] piece_number_d;
	reg en_q;
	reg en_d;
	reg done_d;
	reg done_q;
	
	reg [95:0] location_vectors_w_d;
	reg [95:0] location_vectors_w_q;
	reg [15:0] alive_vectors_w_d;
	reg [15:0] alive_vectors_w_q;
	reg [95:0] location_vectors_b_d;
	reg [95:0] location_vectors_b_q;
	reg [15:0] alive_vectors_b_d;
	reg [15:0] alive_vectors_b_q;
	reg output_player_q;
	reg output_player_d;
	
	reg [1:0] state_d;
	reg [1:0] state_q;
	
	reg [3:0] counter_locations;
	
	parameter RESET   			= 1'b0;
	parameter UPDATE 			= 1'b1;
	
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
	parameter INITIALIZE_LOCATIONS_WHITE = 96'h20928B30D38F0070460850C4; //P1P2P3P4P5P6P7P8R1R2N1N2B1B2Q1K1
	parameter INITIALIZE_LOCATIONS_BLACK = 96'hC31CB3D35DB7E3FE7EEBDEFC; //P1P2P3P4P5P6P7P8R1R2N1N2B1B2Q1K1
	
	assign alive_vectors_w = alive_vectors_w_q;
	assign location_vectors_w = location_vectors_w_q;
	assign output_player = output_player_q;
	assign alive_vectors_b = alive_vectors_b_q;
	assign location_vectors_b = location_vectors_b_q;
	assign dbg_state = state_q;
	assign done = done_q;

	
	always @(*) begin
		location_vectors_w_d = location_vectors_w_q;
		location_vectors_b_d = location_vectors_b_q;
		alive_vectors_w_d = alive_vectors_w_q;
		alive_vectors_b_d = alive_vectors_b_q;
		en_d = en_q;
		move_input_d = move_input_q;
		done_d = done_q;
		piece_number_d = piece_number_q;
		case (state_q)
			RESET : begin
				if (en_q) begin
					state_d = UPDATE;
				end
				else begin
					state_d = RESET;
					done_d = 0;
					counter_locations = P1;
				end
			end
			UPDATE : begin
				if (player == BLACK) begin
					case (piece_number_q)
					P1: begin
						location_vectors_b_d[(P1*6+5):(P1*6)] = move_input_q;
					end
					P2: begin
						location_vectors_b_d[(P2*6+5):(P2*6)] = move_input_q;
					end
					P3: begin
						location_vectors_b_d[(P3*6+5):(P3*6)] = move_input_q;
					end	
					P4: begin
						location_vectors_b_d[(P4*6+5):(P4*6)] = move_input_q;
					end
					P5: begin
						location_vectors_b_d[(P5*6+5):(P5*6)] = move_input_q;
					end
					P6: begin	
						location_vectors_b_d[(P6*6+5):(P6*6)] = move_input_q;
					end
					P7: begin
						location_vectors_b_d[(P7*6+5):(P7*6)] = move_input_q;
					end
					P8: begin
						location_vectors_b_d[(P8*6+5):(P8*6)] = move_input_q;
					end
					R1: begin
						location_vectors_b_d[(R1*6+5):(R1*6)] = move_input_q;
					end
					R2: begin
						location_vectors_b_d[(R2*6+5):(R2*6)] = move_input_q;
					end
					N1: begin
						location_vectors_b_d[(N1*6+5):(N1*6)] = move_input_q;
					end
					N2: begin
						location_vectors_b_d[(N2*6+5):(N2*6)] = move_input_q;
					end
					B1: begin
						location_vectors_b_d[(B1*6+5):(B1*6)] = move_input_q;
					end
					B2: begin
						location_vectors_b_d[(B2*6+5):(B2*6)] = move_input_q;
					end
					Q1: begin
						location_vectors_b_d[(Q1*6+5):(Q1*6)] = move_input_q;
					end
					K1: begin
						location_vectors_b_d[(K1*6+5):(K1*6)] = move_input_q;
					end 
					endcase
					if (location_vectors_w_q[(P1*6+5):(P1*6)] == move_input_q) begin
						alive_vectors_w_d[P1] = 1'b0;
					end
					if (location_vectors_w_q[(P2*6+5):(P2*6)] == move_input_q) begin
						alive_vectors_w_d[P2] = 1'b0;
					end
					if (location_vectors_w_q[(P3*6+5):(P3*6)] == move_input_q) begin
						alive_vectors_w_d[P3] = 1'b0;
					end
					if (location_vectors_w_q[(P4*6+5):(P4*6)] == move_input_q) begin
						alive_vectors_w_d[P4] = 1'b0;
					end
					if (location_vectors_w_q[(P5*6+5):(P5*6)] == move_input_q) begin
						alive_vectors_w_d[P5] = 1'b0;
					end	
					if (location_vectors_w_q[(P6*6+5):(P6*6)] == move_input_q) begin
						alive_vectors_w_d[P6] = 1'b0;
					end
					if (location_vectors_w_q[(P7*6+5):(P7*6)] == move_input_q) begin
						alive_vectors_w_d[P7] = 1'b0;
					end
					if (location_vectors_w_q[(P8*6+5):(P8*6)] == move_input_q) begin
						alive_vectors_w_d[P8] = 1'b0;
					end
					if (location_vectors_w_q[(R1*6+5):(R1*6)] == move_input_q) begin
						alive_vectors_w_d[R1] = 1'b0;
					end
					if (location_vectors_w_q[(R2*6+5):(R2*6)] == move_input_q) begin
						alive_vectors_w_d[R2] = 1'b0;
					end
					if (location_vectors_w_q[(N1*6+5):(N1*6)] == move_input_q) begin
							alive_vectors_w_d[N1] = 1'b0;
					end
					if (location_vectors_w_q[(N2*6+5):(N2*6)] == move_input_q) begin
						alive_vectors_w_d[N2] = 1'b0;
					end
					if (location_vectors_w_q[(B1*6+5):(B1*6)] == move_input_q) begin
						alive_vectors_w_d[B1] = 1'b0;
					end
					if (location_vectors_w_q[(B2*6+5):(B2*6)] == move_input_q) begin
						alive_vectors_w_d[B2] = 1'b0;
					end
					if (location_vectors_w_q[(Q1*6+5):(Q1*6)] == move_input_q && alive_vectors_w_q[Q1] == 1'b1) begin
						alive_vectors_w_d[Q1] = 1'b0;
					end 
					if (location_vectors_w_q[(K1*6+5):(K1*6)] == move_input_q) begin
							alive_vectors_w_d[K1] = 1'b0;
					end
					output_player_d = ~player;
					done_d = 1;
					state_d = RESET;
				end
				else if (player == WHITE) begin
					case (piece_number_q)
					P1: begin
						location_vectors_w_d[(P1*6+5):(P1*6)] = move_input_q;
					end
					P2: begin
						location_vectors_w_d[(P2*6+5):(P2*6)] = move_input_q;
					end
					P3: begin
						location_vectors_w_d[(P3*6+5):(P3*6)] = move_input_q;
					end	
					P4: begin
						location_vectors_w_d[(P4*6+5):(P4*6)] = move_input_q;
					end
					P5: begin
						location_vectors_w_d[(P5*6+5):(P5*6)] = move_input_q;
					end
					P6: begin	
						location_vectors_w_d[(P6*6+5):(P6*6)] = move_input_q;
					end
					P7: begin
						location_vectors_w_d[(P7*6+5):(P7*6)] = move_input_q;
					end
					P8: begin
						location_vectors_w_d[(P8*6+5):(P8*6)] = move_input_q;
					end
					R1: begin
						location_vectors_w_d[(R1*6+5):(R1*6)] = move_input_q;
					end
					R2: begin
						location_vectors_w_d[(R2*6+5):(R2*6)] = move_input_q;
					end
					N1: begin
						location_vectors_w_d[(N1*6+5):(N1*6)] = move_input_q;
					end
					N2: begin
						location_vectors_w_d[(N2*6+5):(N2*6)] = move_input_q;
					end
					B1: begin
						location_vectors_w_d[(B1*6+5):(B1*6)] = move_input_q;
					end
					B2: begin
						location_vectors_w_d[(B2*6+5):(B2*6)] = move_input_q;
					end
					Q1: begin
						location_vectors_w_d[(Q1*6+5):(Q1*6)] = move_input_q;
					end
					K1: begin
						location_vectors_w_d[(K1*6+5):(K1*6)] = move_input_q;
					end 
					endcase
				
						if (location_vectors_b_q[(P1*6+5):(P1*6)] == move_input_q) begin
							alive_vectors_b_d[P1] = 1'b0;
						end
						if (location_vectors_b_q[(P2*6+5):(P2*6)] == move_input_q) begin
							alive_vectors_b_d[P2] = 1'b0;
						end
						
						if (location_vectors_b_q[(P3*6+5):(P3*6)] == move_input_q) begin
							alive_vectors_b_d[P3] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(P4*6+5):(P4*6)] == move_input_q) begin
							alive_vectors_b_d[P4] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(P5*6+5):(P5*6)] == move_input_q) begin
							alive_vectors_b_d[P5] = 1'b0;
						end
					
						if (location_vectors_b_q[(P6*6+5):(P6*6)] == move_input_q) begin
							alive_vectors_b_d[P6] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(P7*6+5):(P7*6)] == move_input_q) begin
							alive_vectors_b_d[P7] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(P8*6+5):(P8*6)] == move_input_q) begin
							alive_vectors_b_d[P8] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(R1*6+5):(R1*6)] == move_input_q) begin
							alive_vectors_b_d[R1] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(R2*6+5):(R2*6)] == move_input_q) begin
							alive_vectors_b_d[R2] = 1'b0;
						end		
						if (location_vectors_b_q[(N1*6+5):(N1*6)] == move_input_q) begin
							alive_vectors_b_d[N1] = 1'b0;
						end
					
					
						if (location_vectors_b_q[(N2*6+5):(N2*6)] == move_input_q) begin
							alive_vectors_b_d[N2] = 1'b0;
						end
					
						if (location_vectors_b_q[(B1*6+5):(B1*6)] == move_input_q) begin
							alive_vectors_b_d[B1] = 1'b0;
						end
					
					
						if (location_vectors_b_q[(B2*6+5):(B2*6)] == move_input_q) begin
							alive_vectors_b_d[B2] = 1'b0;
						end
						
					
						if (location_vectors_b_q[(Q1*6+5):(Q1*6)] == move_input_q) begin
							alive_vectors_b_d[Q1] = 1'b0;
						end 
					
					
						if (location_vectors_b_q[(K1*6+5):(K1*6)] == move_input_q) begin
							alive_vectors_b_d[K1] = 1'b0;
						end
						output_player_d = ~player;
						done_d = 1;
						state_d = RESET;
				end
			end
		endcase
	end
	
	always @(posedge clk) begin
		if (RST) begin
			state_q <= RESET;
			done_q <= 0;
			location_vectors_w_q <= INITIALIZE_LOCATIONS_WHITE;
			location_vectors_b_q <= INITIALIZE_LOCATIONS_BLACK;
			alive_vectors_w_q <= 16'b1111111111111111;
			alive_vectors_b_q <= 16'b1111111111111111;
			piece_number_q <= K1;
			move_input_q <= 0;
			en_q <= 0;
			output_player_q <= BLACK;
		end
		else begin
			location_vectors_w_q <= location_vectors_w_d;
			done_q <= done_d;
			location_vectors_b_q <= location_vectors_b_d;
			alive_vectors_w_q <= alive_vectors_w_d;
			alive_vectors_b_q <= alive_vectors_b_d;
			output_player_q <= output_player_d;
			state_q <= state_d;
			en_q <= en;
			if (en) begin
				move_input_q <= move_input;
				piece_number_q <= piece_number;
			end			
		end
	end
endmodule