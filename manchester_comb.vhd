library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity manchester_comb is
	port(
		h,r,rd : in std_logic;
		Din : in std_logic_vector(7 downto 0);
		Dout : out std_logic_vector (15 downto 0)
		);
		
end manchester_comb;

architecture arch of manchester_comb is
begin
	process(h,r)
	begin
		
		if r = '0' then
			Dout <= (others => '0');
		elsif falling_edge (h) then
			if rd = '1' then
				for i in 0 to 7 loop
					if (Din(i) = '0') then 
						Dout((2*i + 1) downto 2*i) <= "10";
					else 
						Dout((2*i + 1) downto 2*i) <= "01";
					end if;
				end loop;
			end if;
		end if;
	
	end process;
end arch;

