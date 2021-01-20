library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity decod_manchester is
	port(
		datain : in std_logic_vector(15 downto 0); 
		dataout : out std_logic_vector(7 downto 0)
		);
end decod_manchester ;

architecture bhv of decod_manchester is
begin
	process(datain)
	begin
		for i in 0 to 7 loop
			if datain(2*i)='1' and datain(2*i+1)='0' then
				dataout(i) <= '1';
			else
				dataout(i) <= '0';
			end if;
		end loop;
	end process;

end bhv;