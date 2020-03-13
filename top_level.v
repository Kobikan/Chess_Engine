`timescale 1 ns / 1 ps

module top_level(clk50, PS2_CLK, PS2_DAT, dbg_sw1, seg0, seg1, seg2, seg3, LEDR, GPIO_0);
	input clk50, PS2_CLK, PS2_DAT, dbg_sw1;
	output[6:0] seg0, seg1, seg2, seg3;
	output reg [10:0] LEDR;
	output[27:0] GPIO_0;
	
	parameter __UP = 8'h1D;
	parameter __DOWN = 8'h1B;
	parameter __LEFT = 8'h1C;
	parameter __RIGHT = 8'h23;
	parameter __ENTER = 8'h5A;
	parameter __ESC = 8'h76;
	parameter __MOVE = 8'h3A;

	reg[15:0] kb_code, seg_code;
	reg enable_PS2;
	reg[1:0] state;
	reg clk25;
	reg check_ext;
	
	reg cursor_moved;
	reg __ENTER_pressed, __ESC_pressed, __MOVE_pressed;
	reg __CONFIRM_pressed;
	reg [2:0] x_cursor, y_cursor;
	wire [5:0] PS2_cursor;
	
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
	
	//For BoardUpdate.v -> GameLogic.v
	wire done_bu;
	wire player_bu;

	
	//For IO to BoardUpdate.v
	wire [5:0] next_move;
	wire [3:0] pid;
	wire piece_under;
	
	//For BoardUpdate General Output
	wire [95:0] lvw_bu;
	wire [95:0] lvb_bu;
	wire [15:0] avw_bu;
	wire [15:0] avb_bu;
	
	//For Game_logic.v -> AI_Engine.v or IO
	wire piece_ID;
	wire pos_ready;
	wire [1:0] possible_move_P; 
	wire [4:0] possible_move_R;
	wire [2:0] possible_move_N;
	wire [2:0] possible_move_B;
	wire [5:0] possible_move_Q;
	wire [2:0] possible_move_K;
	wire [127:0] moveSet_gm;
	wire done_gm;
	
	wire init_begin_lcd;
	
	//For LCD outputs
	wire [23:0] LCD_BGR_Out;
	wire LCD_HSYNC, LCD_VSYNC, LCD_CLK, LCD_DISP;
	
	assign GPIO_0[0] = LCD_CLK;
	assign GPIO_0[24:1] = LCD_BGR_Out;
	assign GPIO_0[25] = LCD_DISP;
	assign GPIO_0[26] = LCD_HSYNC;
	assign GPIO_0[27] = LCD_VSYNC;
	assign PS2_cursor = {y_cursor, x_cursor};
	
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
		.lcd_clk_outclk0_clk (LCD_CLK), // lcd_clk_outclk0.clk
		.lcd_clk_refclk_clk  (clk50),  //  lcd_clk_refclk.clk
		.lcd_clk_reset_reset (dbg_sw1)  //   lcd_clk_reset.reset
	);
//	
//	AI_Engine engine (
//		.clk(clk50), 
//		.pl(player), 
//		.en(enable_engine),
//		.RST(~dbg_sw1),
//		.location_vectors_w(loc_vec_w),
//		.location_vectors_b(loc_vec_b), 
//		.alive_vectors_w(alive_vec_w),
//		.alive_vectors_b(alive_vec_b),
//		.piece_to_move(decision_piece_ID),
//		.output_move(decision_loc), 
//		.done(finish), 
//		.move_vec_P(possible_move_P), 
//		.move_vec_R(possible_move_R), 
//		.move_vec_N(possible_move_N), 
//		.move_vec_B(possible_move_B), 
//		.move_vec_Q(possible_move_Q), 
//		.move_vec_K(possible_move_K), 
//		.pieceId(piece_ID), 
//		.ready(pos_ready),
//		.end_moves(done_checking)
//	);
	
	board_update_v board_upd(
		.clk(clk50),
		.RST(dbg_sw1),
		.en(__CONFIRM_pressed),
		.player(player_bu),
		.move_input(PS2_cursor),
		.piece_number(pid),
		.location_vectors_w(lvw_bu),
		.location_vectors_b(lvb_bu),
		.alive_vectors_w(avw_bu),
		.alive_vectors_b(avb_bu),
		.dbg_state(),
		.output_player(player_bu),
		.done(done_bu)
	);
	
	generateMoves genMoves(
							.clock(clk50),
                     .reset(dbg_sw1),
                     .enable(done_bu),
                     .player(player_bu),
                     .locationVectorWhite(lvw_bu),
                     .locationVectorBlack(lvb_bu),
                     .aliveVectorWhite(avw_bu),
                     .aliveVectorBlack(avb_bu),
                     .moveSet(moveSet_gm),
							.intdebug(),
							.bitdebug(), 
							.done_gm(done_gm),
							.init_begin(init_begin_lcd)
						);

	
	LCD display(
		//ADD LV,AV, output_player as input to LCD
		//ADD move_output and pid as output from LCD
		.clk12(LCD_CLK),
		.DISP(LCD_DISP),
		.BGR(LCD_BGR_Out),
		.HSYNC(LCD_HSYNC),
		.VSYNC(LCD_VSYNC),
		.reset(dbg_sw1),
		.cursor(PS2_cursor),
		.en(done_gm),
		.enter_pressed(__ENTER_pressed),
		.esc_pressed(__ESC_pressed),
		.confirm_pressed(__CONFIRM_pressed),
		.move_pressed(__MOVE_pressed),
		.lvb(lvb_bu),
		.lvw(lvw_bu),
		.avb(avb_bu),
		.avw(avw_bu),
		.player_in(player_bu),
		.pid(pid),
		.found_piece(piece_under),
		.moveSet(moveSet_gm),
		.init_begin(init_begin_lcd)
	);

	initial begin
		LEDR[0] <= 1'b0;
		x_cursor <= 3'b000;
		y_cursor <= 3'b001;
		__ENTER_pressed <= 1'b0;
		__ESC_pressed <= 1'b0;
		__MOVE_pressed <= 1'b0;
		__CONFIRM_pressed <= 1'b0;
		cursor_moved <= 1'b0;
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
		else begin
			if (dbg_sw1) begin
				seg_code <= 16'hABCD;
			end
			else begin 
				seg_code <= 16'hDCBA;
			end
		end
	end

	always @(posedge clk25) begin
		if (dbg_sw1) begin
			x_cursor <= 3'b100;
			y_cursor <= 3'b000;
		end
		else begin
			if (__CONFIRM_pressed == 1'b1) begin
				__ENTER_pressed <= 1'b0;
				__CONFIRM_pressed <= 1'b0;
			end
			if (scan_ready && cursor_moved == 1'b0) begin
				cursor_moved <= 1'b1;
				if (scanned_code1 == __UP || scanned_code2 == __UP) begin
					if (y_cursor < 3'b111) begin
						y_cursor <= y_cursor + 3'b001;
					end
				end
				else begin
					if (scanned_code1 == __DOWN || scanned_code2 == __DOWN) begin
						if (y_cursor > 3'b000) begin
							y_cursor <= y_cursor - 3'b001;
						end
					end
					else begin
						if (scanned_code1 == __LEFT || scanned_code2 == __LEFT) begin
							if (x_cursor > 3'b000) begin
								x_cursor <= x_cursor - 3'b001;
							end
						end
						else begin
							if (scanned_code1 == __RIGHT || scanned_code2 == __RIGHT) begin
								if (x_cursor < 3'b111) begin
									x_cursor <= x_cursor + 3'b001;
								end
							end
							else begin
								if (scanned_code1 == __ENTER || scanned_code2 == __ENTER) begin
									if (__ENTER_pressed == 1'b1 ) begin
										if (piece_under == 1'b1) begin
											__CONFIRM_pressed<= 1'b1;
										end
										else begin
											__ENTER_pressed <=1'b0;
										end
									end
									else begin
										__ENTER_pressed <= 1'b1;
									end	
								end
								else begin
									if (scanned_code1 == __MOVE || scanned_code2 == __MOVE) begin
											__MOVE_pressed <= 1'b1;
									end
									else begin
										if (scanned_code1 == __ESC || scanned_code2 == __ESC) begin
											__ESC_pressed <= 1'b1;
										end
									end
								end
							end
						end
					end
				end
			end
			else begin
				cursor_moved <= 1'b0;
			end
			if (__ESC_pressed == 1'b1) begin
				if (__MOVE_pressed == 1'b1) begin
					__MOVE_pressed <= 1'b0;
					__ESC_pressed <= 1'b0;
				end
				else begin
					__ENTER_pressed <= 1'b0;
					__ESC_pressed <= 1'b0;
					__CONFIRM_pressed <= 1'b0;
				end
			end
			if (__CONFIRM_pressed == 1'b1) begin
				__MOVE_pressed <= 1'b0;
			end
									
		end
	end

endmodule