library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity chess_engine is
	port(
		  --inputs
		  clk: in std_logic;
		  --pawn locations
		  wp_loc_x, wp_loc_y: in std_logic_vector(23 downto 0); 
		  bp_loc_x, bp_loc_y: in std_logic_vector(23 downto 0);
		  wp_alive, bp_alive : in std_logic_vector(7 downto 0);
		  --rook locations
		  wr_loc_x, wr_loc_y: in std_logic_vector(5 downto 0);
		  br_loc_x, br_loc_y: in std_logic_vector(5 downto 0);
		  wr_alive, br_alive : in std_logic_vector(1 downto 0);
		  --knight locations
		  wn_loc_x, wn_loc_y: in std_logic_vector(5 downto 0);
		  bn_loc_x, bn_loc_y: in std_logic_vector(5 downto 0);
		  wn_alive, bn_alive : in std_logic_vector(1 downto 0);
		  --bishop locations
		  wb_loc_x, wb_loc_y: in std_logic_vector(5 downto 0);
		  bb_loc_x, bb_loc_y: in std_logic_vector(5 downto 0);
		  wb_alive, bb_alive : in std_logic_vector(1 downto 0);
		  --queen locations
		  wq_loc_x, wq_loc_y: in std_logic_vector(2 downto 0);
		  bq_loc_x, bq_loc_y: in std_logic_vector(2 downto 0);
		  wq_alive, bq_alive : in std_logic_vector(0 downto 0);
		  --king locations
		  wk_loc_x, wk_loc_y: in std_logic_vector(2 downto 0);
		  bk_loc_x, bk_loc_y: in std_logic_vector(2 downto 0);
		  wk_alive, bk_alive : in std_logic_vector(0 downto 0);
		  --outputs
		  move_output: out std_logic_vector(9 downto 0); --6bits new loc, 4bits piece number
		  kill_flag: out std_logic_vector(6 downto 0) -- 6bits new loc, 1bit toggle kill
		);
end entity;

architecture behaviour of chess_engine is 
	signal kill_piece: std_logic := '0';
	signal kill_loc: std_logic_vector(5 downto 0) := "000000";
begin
	kill_flag <= kill_piece & kill_loc;
end behaviour;
