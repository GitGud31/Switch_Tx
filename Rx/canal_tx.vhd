library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity canal_tx is
	port(
		h,r 			  : in std_logic;
		wr 				  : in std_logic;
		full			  : out std_logic;
		Tx  			  : out std_logic;
		Din 			  : in std_logic_vector (7 downto 0)  
		);
end canal_tx;

architecture arch of canal_tx is

------------ Signals ------------

signal empty	  			 : std_logic;
signal rd 		  			 : std_logic;
signal INIT_PR 	   			 : std_logic;
signal pr 		   			 : std_logic_vector(143 downto 0);
signal reg1 	   			 : std_logic_vector(15 downto 0); -- changed
signal Dout_fifo, reg2, reg3 : std_logic_vector(7 downto 0);
signal counter 				 : std_logic_vector (6 downto 0);
signal Dout_manchester, reg4 : std_logic_vector (15 downto 0);
signal counter_dec 			 : std_logic_vector (6 downto 0);
signal raz3		 			 : std_logic;
signal ld1, ld2, ld3, ld4, dec1, inc : std_logic; 

----- new signals --------------------------------------------------------
signal sel					     : std_logic_vector(1 downto 0);
signal reg_out       			 : std_logic_vector(1455 downto 0);

signal mux_out				 : std_logic;
signal dec_pr				 : std_logic;
signal dec_regout			 : std_logic;
signal SOF, EOF				 : std_logic;
SIGNAL RAZ2,raz4, inc2		 : std_logic;
SIGNAL C2					 :std_logic_vector(7 downto 0);
signal transmit				 :std_logic;
signal c2equ144, c2equf 	 :std_logic;
signal c3equ13, c3equ14, c3equreg4 	 :std_logic;

signal sel0, sel1, sel2 : std_logic;

------------ Signaux machine -----------

signal r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24 : std_logic;
signal e0, e1, e2, e3 : std_logic;

 



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
------------------- mux --------------------------------
component mux is 
port (
	 h : in std_logic;
	 sel :in std_logic_vector(1 downto 0);
	 Din_OutOfReg1 : in std_logic;
	 Din_OutOFPr: in std_logic;
	 mux_out : out std_logic
	 );
end component;


begin


	U1 : fifo port map (h, Din, rd, wr, empty, full, Dout_fifo);
	U2 : manchester_comb port map (h,r,rd,Dout_fifo,Dout_manchester);
	U3 : mux port map (h,sel, reg1(0), pr(0), mux_out);

--------------------- Séquenceur -------------------------

r1 <= not(e3) and not(e2) and not(e1) and not(e0);
r2 <= empty and not(e3) and not(e2) and not(e1) and e0;
r3 <= not(empty) and not(e3) and not(e2) and not(e1) and e0;
r4 <= not(e3) and not(e2) and e1 and not(e0);
r5 <= not(c2equ144) and not(e3) and not(e2) and e1 and e0;
r6 <= c2equ144 and not(e3) and not(e2) and e1 and e0;
r7 <= not(e3) and e2 and not(e1) and not(e0);
r8 <= not(e3) and e2 and not(e1) and e0;
r9 <= not(e3) and e2 and e1 and not(e0);
r10 <= not(c2equf) and not(e3) and e2 and e1 and e0;
r11 <= c2equf and not(e3) and e2 and e1 and e0;
r12 <= c3equ13 and e3 and NOT(e2) and not(e1) and not(e0);
r13 <= not(c3equ13) and e3 and NOT(e2) and not(e1) and not(e0);
r14 <= not(empty) and e3 and not(e2) and not(e1) and e0;
r15 <= empty and e3 and not(e2) and not(e1) and e0;
r16 <= c3equ14 and e3 and not(e2) and e1 and NOT(e0);
r17 <= e3 and not(e2) and e1 and e0;
r18 <= not(c3equ14) and e3 and not(e2) and e1 and NOT(e0);
r19 <= c3equreg4 and e3 and e2 and NOT(e1) and NOT(e0);
r20 <= not(c3equreg4) and e3 and e2 and NOT(e1) and NOT(e0);
r21 <= not(sof) and e3 and e2 and not(e1) and e0;
r22 <= sof and e3 and e2 and not(e1) and e0;
r23 <= eof and e3 and e2 and e1 and NOT(e0);
r24 <= not(eof) and e3 and e2 and e1 and NOT(e0);


	process(h,r)
	begin
		if r = '1' then
			e0 <= '0'; e1 <= '0'; e2 <= '0'; e3 <= '0';
			raz2 <= '0'; raz3 <= '0'; raz4 <= '0'; init_pr <= '0'; dec_regout <= '0';
			dec_pr <= '0'; inc2 <= '0'; rd <= '0'; ld1 <= '0'; dec1 <= '0'; sel0 <= '0'; sel1 <= '0'; sel2 <= '0';
			inc <= '0'; ld2 <= '0'; ld3 <= '0'; ld4 <= '0'; 
		elsif falling_edge(h) then
			e0 <= r1 or r2 or r4 or r7 or r9 or r12 or r15 or r16 or r17 or r19 or r20 or r21;
			e1 <= r3 or r4 or r5 or r8 or r9 or r10 or R13 OR r16 or r22 or r24;
			e2 <= r6 or r7 or r8 or r9 or r10 or r14 or r18 or r19 or r21 or r22 or r24;
			e3 <= r11 or r12 or r13 or r15 or r16 or r17 or r18 or r19 or r20 or r21 or r22 or r24;  
			raz2 <= r1 or r7;
			raz3 <= r1;
			raz4 <= r1;
			init_pr <= r3;
			dec_regout <= r4 or r9 or r21 or r22 or r24;
			dec_pr <= r4;
			inc2 <= r4 or r9;
			sel0 <= r4;
			rd <= r7;
			ld1 <= r8;
			dec1 <= r9;
			sel1 <= r9;
			inc <= r8;
			ld2 <= r12;
			ld3 <= r16;
			ld4 <= r17;
			sel2 <= r22 or r21;
		end if;
	end process;
--------------------- Registre PR -------------------------
	
	process(h,r,INIT_PR,dec_pr) -- registre PR
	begin
		if r='1' then
			PR <= (others => '0');
		elsif rising_edge(h) then
			if INIT_PR = '1'then
 				PR <= x"666566666666666666666666666666666666";
				
			elsif dec_pr = '1' then  
				pr <= '0' & pr(143 downto 1); 
				
			end if;
		end if; -- reset
	end process;
	
	
--------------------- Registre reg1 --------------------------
	
	process(h,ld1,dec1) 
	begin
		if rising_edge(h) then
			if ld1 = '1' then
				reg1 <= Dout_manchester; 
			elsif dec1 = '1' then
				reg1 <= '0' & reg1(15 downto 1); 
			end if;
		end if;  
	end process;

	
--------------------- compteur -------------------------
	
	process(r,raz3,h,inc)
	begin
		if r = '1' then
			counter <= (others => '0');
		elsif rising_edge(h) then
			if raz3 = '1' then
				counter <= (others => '0');
			elsif inc = '1' then
				counter <= counter +1;
			end if;
			if counter = 13 then 
				c3equ13 <= '1';
			elsif counter = 14 then 
				c3equ13 <= '0';
				c3equ14 <= '1';
			elsif counter = reg4 and counter /= 0 then
				c3equreg4 <= '1';
			else
				c3equ13 <= '0';
				c3equ14 <= '0';
				c3equreg4 <= '0';
			end if;
		end if; 
	end process;
	
	
--------------------- c2 -------------------------
	
	process(r,raz2,h,inc2)
	begin
		if r = '1' then
			c2 <= (others => '0');
		elsif rising_edge(h) then
			if raz2 = '1' then
				c2 <= (others => '0');
			elsif inc2 = '1' then
				c2 <= c2 +1;
			end if;
--		elsif falling_edge(h) then
			if c2 = 15 then 
				c2equf <= '1';
			elsif c2 = 143 then 
				c2equf <= '0';
				c2equ144 <= '1';
			else 
				c2equ144 <= '0';
				c2equf <= '0';
			end if;
		end if;
	end process;
	
--------------------- Registres reg2 reg3 reg4 -------------------------
	
	process(h,ld2, ld3, ld4)
	begin
		if rising_edge(h) then
			if raz4 = '1' then
				reg4 <= (others => '0');
			elsif ld2 ='1' then
				reg2 <= Dout_fifo;
			elsif ld3 = '1' then
				reg3 <= Dout_fifo;
			elsif ld4 ='1' then
				reg4 <= (reg2 & reg3) + 4 + counter;
			end if;
		end if; 
	end process;
			
---------------- regout ------------------------- 

	process(h, r,dec_regout,transmit)
	begin
		if r = '1' then 
			reg_out <= (others => '0');
		elsif falling_edge(h) then
			if dec_regout = '1'  then
				Tx <= reg_out(0);
				reg_out <= mux_out & reg_out(1455 downto 1);
			end if;
			
			if reg_out(1 downto 0) /= "00" then
				sof <= '1';
				eof <= '0';
			elsif (reg_out(2 downto 0) = "000") and (counter = reg4) and (counter /= 0) then
				eof <= '1';
			else
				sof <= '0';
				eof <= '0';
			end if;
		end if;  
	end process;
	
---------------- select ------------------------- 

	process(h,r, sel0, sel1, sel2)
	begin
		if r = '1' then
			sel <= "00";
		elsif rising_edge(h) then
			if sel0 = '1' then
				sel <= "00";
			elsif sel1 = '1' then
				sel <= "01";
			elsif sel2 = '1' then
				sel <= "10";

			end if;
		end if;
	end process;

	
	
end arch;
		
		
		
		
		
		
		
		
		
		
 

 