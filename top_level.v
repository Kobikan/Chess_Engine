`timescale 1 ns / 1 ps

module top_level(clk50, reset_kb, PS2_CLK, PS2_DAT, dbg_sw1, seg0, seg1, seg2, seg3, led0, DRAM_ADDR, DRAM_BA, DRAM_CAS_N, DRAM_RAS_N, DRAM_CLK, DRAM_UDQM, DRAM_LDQM, DRAM_DQ, DRAM_CKE, DRAM_CS_N, DRAM_WE_N);
	input reset_kb, clk50, PS2_CLK, PS2_DAT, dbg_sw1;
	output[6:0] seg0, seg1, seg2, seg3;
	output led0;
	output [12:0] DRAM_ADDR;
	output [1:0] DRAM_BA;
	output DRAM_CAS_N, DRAM_RAS_N, DRAM_CLK;
	output DRAM_CKE, DRAM_CS_N, DRAM_WE_N;
	output DRAM_UDQM;
	output DRAM_LDQM;
	
	inout [15:0] DRAM_DQ;
	
	parameter __UP = 8'h1D;
	parameter __DOWN = 8'h1B;
	parameter __LEFT = 8'h1C;
	parameter __RIGHT = 8'h23;
	parameter ENTER = 8'h5A;
	parameter ESC = 8'h76;
	
	reg[15:0] kb_code, seg_code;
	reg enable_PS2;
	reg[1:0] state;
	reg clk25;
	reg check_ext;
	reg led0;
	
	//For keyboard.v
	wire[7:0] scanned_code1, scanned_code2, scanned_code3;
	wire scan_ready;
	wire [6:0] seg0, seg1, seg2, seg3;
	
	//For AI_Engine.v
	wire player_sel;
	wire enable_engine;
	wire [95:0] loc_vec_w, loc_vec_b;
	wire [15:0] alive_vec_w, alive_vec_b;
	wire [3:0] decision_piece_ID;
	wire [5:0] decision_loc;
	wire finish;
	
	//For Game_logic.v -> AI_Engine.v
	wire piece_ID;
	wire pos_ready;
	wire [1:0] possible_move_P; 
	wire [4:0] possible_move_R;
	wire [2:0] possible_move_N;
	wire [2:0] possible_move_B;
	wire [5:0] possible_move_Q;
	wire [2:0] possible_move_K;
	wire done_checking;
	
	keyboard keybd( 
		.clk50(clk50),
		.PS2_CLK(PS2_CLK), 
		.PS2_DAT(PS2_DAT), 
		.scan_code1(scanned_code1),
		.scan_code2(scanned_code2),
		.scan_code3(scanned_code3),		
		.scan_ready(scan_ready)
	);
	
	seven_segment seven_seg(
		.code(seg_code),
		.seg0(seg0),
		.seg1(seg1),
		.seg2(seg2),
		.seg3(seg3),
		.clk50(clk50)
	);
	
	nios_system NiosII (
		.clk_1_clk(clk50),
		.sdram_wire_addr(DRAM_ADDR),
		.sdram_wire_ba(DRAM_BA),
		.sdram_wire_cas_n(DRAM_CAS_N),
		.sdram_wire_cke(DRAM_CKE),
		.sdram_wire_cs_n(DRAM_CS_N),
		.sdram_wire_dq(DRAM_DQ),
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),
		.sdram_wire_ras_n(DRAM_RAS_N),
		.sdram_wire_we_n(DRAM_WE_N),
		.reset_reset(~dbg_sw1),
		.sdram_clk_clk(DRAM_CLK)
	);
	
	AI_Engine engine (
		.clk(clk50), 
		.pl(player), 
		.en(enable_engine),
		.RST(~dbg_sw1),
		.location_vectors_w(loc_vec_w),
		.location_vectors_b(loc_vec_b), 
		.alive_vectors_w(alive_vec_w),
		.alive_vectors_b(alive_vec_b),
		.piece_to_move(decision_piece_ID),
		.output_move(decision_loc), 
		.done(finish), 
		.move_vec_P(possible_move_P), 
		.move_vec_R(possible_move_R), 
		.move_vec_N(possible_move_N), 
		.move_vec_B(possible_move_B), 
		.move_vec_Q(possible_move_Q), 
		.move_vec_K(possible_move_K), 
		.pieceId(piece_ID), 
		.ready(pos_ready),
		.end_moves(done_checking)
	);

	

	initial begin
		led0 <= 1'b0;
	end
	
	always @(posedge clk50) begin //Clk divider by 2.
		clk25 <= ~clk25;
	end
	
	always @(posedge clk25) begin
		if (scan_ready) begin
			if (scanned_code1 != 8'hF0 && scanned_code1 != 8'hE0) begin
				seg_code <= {8'h00, scanned_code1};
			end
			else begin
				if (scanned_code2 != 8'hF0 && scanned_code2 != 8'hE0) begin
					seg_code <= {8'h01, scanned_code2};
				end
			end
		end
	end

	always @(posedge clk25) begin
		if (scan_ready && (scanned_code1 == __UP || scanned_code1 == __DOWN || scanned_code1 == __LEFT || scanned_code1 == __RIGHT || scanned_code1 == ENTER || scanned_code1 == ESC || (scanned_code2 == __UP || scanned_code2 == __DOWN || scanned_code2 == __LEFT || scanned_code2 == __RIGHT || scanned_code2 == ENTER || scanned_code2 == ESC))) begin
			led0 <= 1'b1;
		end
		else begin
			led0 <= 1'b0;
		end
	end

endmodule