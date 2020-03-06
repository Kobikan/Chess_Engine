//Author: K. Pandya

module keyboard (clk50, PS2_CLK, PS2_DAT, scan_ready, scan_code1, scan_code2, scan_code3);
	input clk50, PS2_CLK, PS2_DAT;
	output reg [7:0] scan_code1, scan_code2, scan_code3;
	output reg scan_ready;
	
	parameter START = 4'h0;
	parameter CLK_LO1 = 4'h1;
	parameter CLK_HI1 = 4'h2;
	parameter SCAN1 = 4'h3;
	parameter CLK_LO2 = 4'h4;
	parameter CLK_HI2 = 4'h5;
	parameter SCAN2 = 4'h6;
	parameter CLK_LO3 = 4'h7;
	parameter CLK_HI3 = 4'h8;
	parameter SCAN3 = 4'h9;
	
	reg[7:0] PS2_filter_CLK;
	reg[7:0] PS2_filter_DAT;
	reg[4:0] state;
	reg [4:0] bits_read = 0;
	reg [10:0] bitstream1, bitstream2, bitstream3;
	reg [7:0] bs_code1, bs_code2, bs_code3;
	reg PS2_FCLK;
	reg PS2_FDAT;
	reg led0;
	reg exit_count_fin;
	reg clk25 = 0;
	
	initial begin
		state <= START;
	end
	
	always @(posedge clk50) begin //Clk divider by 2.
		clk25 <= ~clk25;
	end
	
	always @(posedge clk25) begin //Filter PS2 clk and dat.
		PS2_filter_CLK <= {PS2_CLK, PS2_filter_CLK[7:1]};
		PS2_filter_DAT <= {PS2_DAT, PS2_filter_DAT[7:1]};
		
		if (PS2_filter_CLK == 8'hFF)
			PS2_FCLK <= 1'b1;
		else begin
			if (PS2_filter_CLK == 8'h00)
				PS2_FCLK <= 1'b0;
		end
		
		if (PS2_filter_DAT == 8'hFF)
			PS2_FDAT <= 1'b1;
		else begin
			if (PS2_filter_DAT == 8'h00)
				PS2_FDAT <= 1'b0;
		end
	end
	
	always @(posedge clk25) begin
		case(state)
			START:
				begin
					scan_ready <= 1'b0;
					if (PS2_FDAT == 1'b1)
						state <= START;
					else
						state <= CLK_LO1;
				end
			CLK_LO1:
				begin
					if (bits_read < 4'hB) begin
						if (PS2_FCLK != 1'b0)
							state <= CLK_LO1;
						else begin
							state <= CLK_HI1;
							bitstream1 <= {PS2_FDAT, bitstream1[10:1]};
							bits_read <= bits_read + 4'h1;
						end
					end
					else
						state <= SCAN1;
				end
			CLK_HI1:
				begin 
					if (PS2_FCLK != 1'b1)
						state <= CLK_HI1;
					else
						state <= CLK_LO1;
				end
			SCAN1:
				begin
					bits_read <= 4'h0;
					bs_code1 <= bitstream1[8:1];
					state <= CLK_LO2;
				end
			CLK_LO2:
				begin
					if (bits_read < 4'hB) begin
						if (PS2_FCLK != 1'b0)
							state <= CLK_LO2;
						else begin
							state <= CLK_HI2;
							bitstream2 <= {PS2_FDAT, bitstream2[10:1]};
							bits_read <= bits_read + 4'h1;
						end
					end
					else
						state <= SCAN2;
				end
			CLK_HI2:
				begin 
					if (PS2_FCLK != 1'b1)
						state <= CLK_HI2;
					else
						state <= CLK_LO2;
				end
			SCAN2:
				begin
					bits_read <= 4'h0;
					bs_code2 <= bitstream2[8:1];
					state <= CLK_LO3;
				end
			CLK_LO3:
				begin
					if (bits_read < 4'hB) begin
						if (PS2_FCLK != 1'b0)
							state <= CLK_LO3;
//							if (exit_count_fin)
//								state <= SCAN3;
						else begin
							state <= CLK_HI3;
							bitstream3 <= {PS2_FDAT, bitstream3[10:1]};
							bits_read <= bits_read + 4'h1;
						end
					end
					else
						state <= SCAN3;
				end
			CLK_HI3:
				begin 
					if (PS2_FCLK != 1'b1)
						state <= CLK_HI3;
					else
						state <= CLK_LO3;
				end
			SCAN3:
				begin
					bits_read <= 4'h0;
					bs_code3 <= bitstream3[8:1];
					state <= START;					
					scan_code1 <= bs_code1;
					scan_code2 <= bs_code2;
					scan_code3 <= bs_code3;
					scan_ready <= 1'b1;
				end	
		endcase
	end

endmodule