library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity Tx is
	port(
		h,r : in std_logic;
		wr : in std_logic;
		Din : in std_logic_vector (7 downto 0);
		Tx : out std_logic;
		empty_out, rd_out : out std_logic;
		fifo_out : out std_logic_vector(7 downto 0) 
		);
		
end Tx;

architecture arch of Tx is

------------ Signals ------------

signal empty, full : std_logic;
signal rd : std_logic;
signal start : std_logic;
signal pr : std_logic_vector(143 downto 0);
signal reg1 : std_logic_vector(1311 downto 0);
signal Dout_fifo, reg2, reg3 : std_logic_vector(7 downto 0);
signal counter : std_logic_vector (6 downto 0);
signal Dout_manchester, reg4 : std_logic_vector (15 downto 0);

------------ Components ------------

----- Codeur Manchester -----
component manchester_comb is
	port(
		h,r,rd : in std_logic;
		Din : in std_logic_vector(7 downto 0);
		Dout : out std_logic_vector (15 downto 0)
		);
end component;

----- Pile fifo -----
component fifo
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;




begin
	
	process(h,r)
	begin
		if r = '0' then 
			reg1 <= (others => '0');
			reg2 <= (others => '0');
			reg3 <= (others => '0');
			reg4 <= (others => '0');
			pr <= (others => '0');
			counter <= (others => '0');
			
		elsif falling_edge (h) then
			if empty = '0' then      -- si la pile n'est pas vide
				if start = '0' then  -- ce test permet de ne cherger pr par sa valeur de pr�ambule qu'une seule fois au debut
					start <= '1';
					pr <= x"666566666666666666666666666666666666";
				end if;
				rd <= '1';           -- autouriser la lecture de la pile
				reg1 <= Dout_manchester & reg1(1311 downto 16);  -- d�calage 16 et chargement du reg1 en m�me temps
				counter <= counter +1;  -- incr�mentation du compteur apr�s le d�calage
				if counter = 13 then  -- si on lit le 13�me oct 
					reg2 <= Dout_fifo;  -- on le charge dans reg2
				elsif counter = 14 then -- si on lit le 14�me oct
					reg3 <= Dout_fifo;  -- on le charge dans reg3
					reg4 <= counter + 4 + (reg3 & reg2); -- puis on charge reg4 par counter + le contenu des reg3 et reg2 concaten� + 4 (taille de la trame) 
				end if;
			else -- si la pile est vide (on a termin� le chargement de la trame dans reg1)
				rd <= '0';  -- on arr�te la lecture de la pile
				if reg4 = counter then  -- si on est arriv� � la fin de la trame
					if reg1(2 downto 0) = "000" then  -- s'assurer que la trame occupe les MSB de reg1 sinn on d�cale 
						reg1 <= x"0000" & reg1(1311 downto 16); 
					else
						if pr(2 downto 0) = "000" then  -- tester si la trame � �t� envoy� enti�rement 
							start <= '0';               -- si oui, remise � z�ro de tous les registres
							reg1 <= (others => '0');
							reg2 <= (others => '0');
							reg3 <= (others => '0');
							reg4 <= (others => '0');
							pr <= (others => '0');
							counter <= (others => '0');
							Tx <= '0';
						else                            -- sinon on fait le d�calage  
							Tx <= pr(0);  -- transmission du lsb de pr via TX                
							pr <= reg1(0) & pr(143 downto 1);  --d�calage de pr en y injectant lsb de reg1
							reg1 <= '0' & reg1(1311 downto 1);  -- d�calage de reg1 en y injectant un 0
						
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	
	U1 : fifo port map (h, Din, rd, wr, empty, full, Dout_fifo);
	U2 : manchester_comb port map (h,r,rd,Dout_fifo,Dout_manchester);
	empty_out <= empty;
	rd_out <= rd;
	fifo_out <= Dout_fifo;
				
end arch;
		
		
		
		
		
		
		
		
		
		
 

 