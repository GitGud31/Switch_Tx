Library ieee;
use ieee.std_logic_1164.all;

entity BM_Tx is
	Port
	(
		Din,h,reset: in std_logic;
		PR : out std_logic_vector(1455 downto 0)
	);
end BM_Tx;

architecture arch of BM_Tx is

signal reg_dec : std_logic_vector(1455 downto 0); 

begin
	process(h,reset)
	begin
		if reset ='0' then
			reg_dec <= (others => '0');
		elsif falling_edge(h) then
			reg_dec <= Din & reg_dec(1455 downto 1);
		end if;
	end process;
	PR <= reg_dec;
end arch;
			