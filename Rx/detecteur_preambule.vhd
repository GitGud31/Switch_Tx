library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed;
use ieee.std_logic_unsigned;
use ieee.numeric_std;

entity detecteur_preambule is 
port(
	h,r,d_in : in std_logic;
	--enable : in std_logic;
	match, sfd : out std_logic
);
end detecteur_preambule;

architecture arec of detecteur_preambule is 
signal tester1 : std_logic_vector(15 downto 0) := "0110011001100110";
signal tester2 : std_logic_vector(15 downto 0) := "0110011001100101";
signal correct : natural;
signal rx_BITcounter  : natural;
signal rx_BYTEcounter : natural;
--signal d_in : std_logic;


begin 

	process(h,r)

	begin 
		if r = '1' then 
			rx_BITcounter <= 0; 
			rx_BYTEcounter <= 0;
			correct <= 0;
			
			
		elsif falling_edge(h) then 

			if(rx_BYTEcounter < 8) then
				if(rx_BITcounter < 16) then
					
					if (tester1(rx_BITcounter) = d_in) then
						correct <= correct + 1;
						rx_BITcounter <= rx_BITcounter + 1;
					end if;
					
				else 
					correct <= 0;
					if rx_BYTEcounter < 7 then
						if (tester1(0) = d_in) then
							correct <= 1;
						end if;
					end if;
					rx_BITcounter <= 1;
					rx_BYTEcounter <= rx_BYTEcounter + 1;
				end if;
						
			elsif rx_BYTEcounter = 8 then
				if(rx_BITcounter < 16) then
					
					if (tester2(rx_BITcounter) = d_in) then
						correct <= correct + 1;
						rx_BITcounter <= rx_BITcounter + 1;
					end if;
				else 	
					correct <= 0;
					rx_BITcounter <= 0;
					rx_BYTEcounter <= 0;
					
				end if; -- BIT by BIT tester
			end if; --rx_BITcounter
		end if; --rx_BYTEcounter
			
		
	end process;

--	process(h)
--	begin
--		if rising_edge(h) then
--			if enable = '1' then
--				d_in <= data_in;
--			end if;
--		end if;
--	end process;
--	
	process(h,r,correct)
	begin
		if r = '1' then 
			match <= '0';
			sfd <= '0';
		elsif rising_edge(h) then
			if (correct = 15) and (rx_BYTEcounter = 8) and (rx_BITcounter = 16) then
				sfd <= '1';
	
			elsif (correct = 16) and (rx_BYTEcounter < 8) and (rx_BITcounter = 16)  then 
				match <= '1';
			else 
				match <= '0';
				sfd <= '0';	
			end if;
		end if;
	end process;
	
	
					
			

end arec;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		