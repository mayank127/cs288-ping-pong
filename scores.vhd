----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:43:10 04/13/2013 
-- Design Name: 
-- Module Name:    scores - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scores is
	PORT (
			scr : in std_logic_vector(2 downto 0);
			a1 : out std_logic_vector(9 downto 0);
			a2 : out std_logic_vector(9 downto 0);
			a3 : out std_logic_vector(9 downto 0);
			a4 : out std_logic_vector(9 downto 0);
			a5 : out std_logic_vector(9 downto 0);
			a6 : out std_logic_vector(9 downto 0);
			a7 : out std_logic_vector(9 downto 0);
			a8 : out std_logic_vector(9 downto 0);
			a9 : out std_logic_vector(9 downto 0);
			a10 : out std_logic_vector(9 downto 0)
		);
		
end scores;

architecture Behavioral of scores is

begin
process(scr)  --each of the matrix is of size 10 x 10 and where each has a shape according t0 the number
begin
	case scr is
		when "000" => 
			a1<="1111111111";
			a2<="1111111111";
			a3<="1110000111";
			a4<="1110000111";
			a5<="1110000111";
			a6<="1110000111";
			a7<="1110000111";
			a8<="1110000111";
			a9<="1111111111";
			a10<="1111111111";

		when "001" =>
			a1<="0001111000";
			a2<="0110111000";
			a3<="1000111000";
			a4<="0000111000";
			a5<="0000111000";
			a6<="0000111000";
			a7<="0000111000";
			a8<="0000111000";
			a9<="1111111111";
			a10<="1111111111";

		when "010" =>
			a1<="1111111111";
			a2<="1111111111";
			a3<="0000000111";
			a4<="0000000111";
			a5<="1111111111";
			a6<="1111111111";
			a7<="1111000000";
			a8<="1111000000";
			a9<="1111111111";
			a10<="1111111111";

		when "011" =>
			a1<="1111111111";
			a2<="1111111111";
			a3<="0000000111";
			a4<="0000000111";
			a5<="1111111111";
			a6<="1111111111";
			a7<="0000000111";
			a8<="0000000111";
			a9<="1111111111";
			a10<="1111111111";
		when "100" =>

			a1<="1110000111";
			a2<="1110000111";
			a3<="1110000111";
			a4<="1111111111";
			a5<="1111111111";
			a6<="0000001111";
			a7<="0000001111";
			a8<="0000001111";
			a9<="0000001111";
			a10<="0000001111";
		when "101" =>
			a1<="1111111111";
			a2<="1111111111";
			a3<="1111000000";
			a4<="1111000000";
			a5<="1111111111";
			a6<="1111111111";
			a7<="0000011111";
			a8<="0000011111";
			a9<="1111111111";
			a10<="1111111111";
		
		when "110" =>
		
			a1<="1111111111";
			a2<="1111111111";
			a3<="1111000000";
			a4<="1111000000";
			a5<="1111111111";
			a6<="1111111111";
			a7<="1100001111";
			a8<="1100001111";
			a9<="1111111111";
			a10<="1111111111";
		when "111" =>
		
			a1<="1111111111";
			a2<="1111111111";
			a3<="1111111111";
			a4<="0000001111";
			a5<="0000011111";
			a6<="0000011110";
			a7<="0000011110";
			a8<="0000111110";
			a9<="0000111100";
			a10<="0000111100";
		when others =>
			a1<="1111111111";
			a2<="1111111111";
			a3<="1111111111";
			a4<="1111111111";
			a5<="1111111111";
			a6<="1111111111";
			a7<="1111111111";
			a8<="1111111111";
			a9<="1111111111";
			a10<="1111111111";
end case;
end process;
end Behavioral;

