library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity data_generator is
port(
clk,reset,full : in std_logic;
writ_e : out std_logic;
data_out : out std_logic_vector(7 downto 0)
);
end data_generator;
architecture bhv of data_generator is

TYPE table IS ARRAY (0 TO 18) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  CONSTANT data: table := 
  (x"00", x"00", x"00", x"00",x"00",x"01",-- adresse source
   x"00", x"00", x"00", x"00",x"00",x"02", -- adresse dest
   x"00", x"01", 							-- taille données
   x"ff",									-- données
   x"A6", x"01", x"7E", x"9E" );
signal count : integer range 0 to 127;
signal countp : std_logic_vector(6 downto 0);
signal inc,arret,e0,r1,r2,r3,r4 : std_logic;
constant data_number : integer range 0 to 127 := 19; 

begin
--iterp <= conv_std_logic_vector(iter,7);
data_out <= data(count);

	process(clk,reset)
	begin
		if reset='1' then
			count <= 0;
		elsif rising_edge(clk) then
			if inc='1' then
				count <= count + 1;
			else
				count <= count;
			end if;
		end if;
	end process;

	process(count)
	begin
		if count = data_number - 1 then 
			arret <= '1';
		else
			arret <= '0';
		end if;
	end process;


	r1 <= full and not(e0);
	r2 <= not(full) and not(e0);
	r3 <= not(arret) and (e0);
	r4 <= arret and (e0);

	process(clk,reset)
	begin
		if reset='1' then
			e0 <= '0';
			writ_e <= '0';
			inc <= '0';
		elsif falling_edge(clk) then
			e0 <= r2 or r4;
			writ_e <= r2;
			inc <= r3;
		end if;
	end process;

end bhv;



