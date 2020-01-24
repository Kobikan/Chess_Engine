`timescale 1ns / 1ps

module ai_engine( clk, pl, en, RST, location_vectors_w, location_vectors_b, alive_vectors_w, alive_vectors_b, piece_to_move, output_move, done);
	input clk;
	input en;
	input RST;
	input pl;
	output [95:0] location_vectors_b;
	output [95:0] location_vectors_w;
	output [15:0] alive_vectors_w;
	output [15:0] alive_vectors_b;
	output [5:0] output_move;
	output [3:0] piece_to_move;
	output done;
	
	// parameters that will be written as constants in code
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
	parameter MAX_DEPTH 			= 5;
	parameter HEUR_WIDTH       = 10;
	//states in the fsm
	parameter RESET   			= 4'b0000;
	parameter EXPLORE 			= 4'b0001;
	// end states
	
	reg [5:0] best_move_d;
	reg [5:0] best_move_q;
	reg [5:0] last_move_d;
	reg [5:0] last_move_q;
	reg [1:0] state_d;
	reg [1:0] state_q;
	reg [3:0] piece_to_move_q;
	reg [3:0] piece_to_move_d;
	reg done_q;
	reg done_d;
	reg en_q;
	reg pl_q;
	reg pl_d;
	
	assign output_move = best_move_q;
	assign done = done_q;
	assign piece_to_move = piece_to_move_q;
	
	wire [HEUR_WIDTH:0] alpha_w;
	reg signed [HEUR_WIDTH:0] alpha_d;
	reg signed [HEUR_WIDTH:0] alpha_q;

	wire [HEUR_WIDTH:0] beta_w;
	reg signed [HEUR_WIDTH:0] beta_d;
	reg signed [HEUR_WIDTH:0] beta_q;

	wire [HEUR_WIDTH:0] best_value_w;
	reg signed [HEUR_WIDTH:0] best_value_d;
	reg signed [HEUR_WIDTH:0] best_value_q;

	reg signed [HEUR_WIDTH:0] max_p_d;
	reg signed [HEUR_WIDTH:0] max_p_q;
	
	always @( * ) begin
		done_d = done_q;	
		best_move_d = best_move_q;
		max_p_d = max_p_q;	
		best_value_d = best_value_q;
		alpha_d = alpha_w;
		beta_d = beta_w;
		last_move_d = last_move_q;
		piece_to_move_d = piece_to_move_q;
	
		case ( state_q )
			RESET: begin
						if ( en_q ) begin
							state_d = EXPLORE;
							best_move_d = 0;
							piece_to_move_d = 0;
							last_move_d = 0;
							pl_d     = pl_q;
							alpha_d = 11'b10000000001; //very low neg
							beta_d = 11'b01111111111; //very high pos
							
						end
						else begin
							state_d = RESET;
						end
						done_d = 1'b0;				
					end
		endcase
	end
	
	// all flip flops
	always @(posedge clk) begin
		if ( RST ) begin
			state_q <= RESET;
			done_q  <= 0;
			last_move_q     <= 0;
			best_move_q     <= 0;
			piece_to_move_q <= 0;
			best_value_q <= 0;
			alpha_q <= 0;
			beta_q <= 0;
			pl_q <= BLACK;
			max_p_q <= 0;
			en_q <= 0;
		end
		else begin
			en_q <= en;
			piece_to_move_q <= piece_to_move_d;
			state_q <= state_d;
			best_move_q <= best_move_d;
			last_move_q <= last_move_d;
			done_q <= done_d;
			best_value_q <= best_value_d;
			alpha_q <= alpha_d;
			beta_q <= beta_d;
			max_p_q <= max_p_d;
			pl_q <= pl_d;
		end
	end
endmodule
