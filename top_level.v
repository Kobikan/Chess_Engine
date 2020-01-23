module top_level(clk50, reset_kb, PS2_CLK, PS2_DAT, dbg_sw1, seg0, seg1, seg2, seg3, led0);
	input reset_kb, clk50, PS2_CLK, PS2_DAT, dbg_sw1;
	output[6:0] seg0, seg1, seg2, seg3;
	output led0;
	
	parameter ARROW_UP = 8'h75;
	parameter ARROW_DOWN = 8'h72;
	parameter ARROW_LEFT = 8'h6B;
	parameter ARROW_RIGHT = 8'h74;
	parameter ENTER = 8'h5A;
	parameter ESC = 8'h76;
	
	reg[15:0] kb_code, seg_code;
	reg enable_PS2;
	reg[1:0] state;
	reg clk25;
	reg check_ext;
	reg led0;
	reg[31:0] dbg_counter;
	
	wire[7:0] scanned_code1, scanned_code2, scanned_code3;
	wire scan_ready;
	wire [6:0] seg0, seg1, seg2, seg3;
	
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
	
	initial begin
		led0 <= 1'b0;
		dbg_counter <= 31'h0000_0000;
	end
	
	always @(posedge clk50) begin //Clk divider by 2.
		clk25 <= ~clk25;
	end
	
	always @(posedge clk50) begin
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

	always @(posedge clk50) begin
		if (scan_ready && (scanned_code1 == ARROW_UP || scanned_code1 == ARROW_DOWN || scanned_code1 == ARROW_LEFT || scanned_code1 == ARROW_RIGHT || scanned_code1 == ENTER || scanned_code1 == ESC || (scanned_code2 == ARROW_UP || scanned_code2 == ARROW_DOWN || scanned_code2 == ARROW_LEFT || scanned_code2 == ARROW_RIGHT || scanned_code2 == ENTER || scanned_code2 == ESC))) begin
			led0 <= 1'b1;
		end
		else begin
			led0 <= 1'b0;
		end
	end

endmodule