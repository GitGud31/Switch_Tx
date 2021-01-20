library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mux is 

port(
	 h : in std_logic;
	 sel :in std_logic_vector(1 downto 0);
	 Din_OutOfReg1 : in std_logic;
	 Din_OutOFPr: in std_logic;
	 mux_out : out std_logic
	 );
	 
end entity;

architecture amux of mux is 
begin 

process(h)
begin
	if rising_edge(h) then
		if sel = "00" then
			mux_out <= Din_OutOFPr;
		elsif sel = "01" then
			mux_out <= Din_OutOfReg1;
		else
			mux_out <= '0';	
		end if;
	end if;
end process;
end amux ;	 
	 
	 