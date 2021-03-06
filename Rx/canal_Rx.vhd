library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity canal_Rx is
port( 
	h,r, rd : in std_logic;
	rx_out, match_out, sfd_out, raz_out: out std_logic;
	word_used : out std_logic_vector(6 downto 0);
	fifo_out : out std_logic_vector(7 downto 0);
	etat : out std_logic_vector(2 downto 0);
	full_out, wr_out : out std_logic;
	manchester : out std_logic_vector(7 downto 0)
	);
end entity;

architecture arch of canal_Rx is

-- ============== Signals ====================
	signal reg_in : std_logic_vector(1455 downto 0);
	signal dec1, SOF, EOF : std_logic;
	signal reg_16 : std_logic_vector(15 downto 0);
	signal dec2 : std_logic;
	signal C16 : std_logic_vector(7 downto 0);
	signal raz, inc, C16equF : std_logic;
	signal enable, match, sfd : std_logic;
	signal manchester_out : std_logic_vector(7 downto 0);
	signal wr, full, empty : std_logic;
	
	signal din_preambule : std_logic;
	signal din_reg16 : std_logic;
	
	
	signal e0,e1,e2,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13 : std_logic;
	
	signal plein, ecris : std_logic;
	signal data : std_logic_vector(7 downto 0);
	signal rx : std_logic; 

-- ============== Components ================

	---- FIFO ----
	component fifo_rx IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdreq		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			empty		: OUT STD_LOGIC ;
			full		: OUT STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			usedw		: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END component;

--	component fifo IS
--	PORT
--	(
--		clock		: IN STD_LOGIC ;
--		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		rdreq		: IN STD_LOGIC ;
--		wrreq		: IN STD_LOGIC ;
--		empty		: OUT STD_LOGIC ;
--		full		: OUT STD_LOGIC ;
--		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
--	);
--	END component;
	
	
	---- d�t�cteur de pr�ambule ----
	component detecteur_preambule is 
		port(
			h,r,d_in : in std_logic;
			--enable : in std_logic;
			match, sfd : out std_logic
		);
	end component;
	
	---- d�codeur Manchester ----
	component decod_manchester is
	port(
		datain : in std_logic_vector(15 downto 0); 
		dataout : out std_logic_vector(7 downto 0)
		);
	end component ;
	
	
	component data_generator is
	port(
		clk,reset,full : in std_logic;
		writ_e : out std_logic;
		data_out : out std_logic_vector(7 downto 0)
		);
	end component;
	
	
	component canal_tx is
	port(
		h,r 			  : in std_logic;
		wr 				  : in std_logic;
		full			  : out std_logic;
		Tx  			  : out std_logic;
		Din 			  : in std_logic_vector (7 downto 0)  
		);
	end component;

-- ============================================

begin
	
	match_out <= match;
	sfd_out <= sfd;
	rx_out <= rx; 
	etat <= e2 & e1 & e0;
	manchester <= manchester_out;
	raz_out <= raz;
	full_out <= full;
	wr_out <= wr;

	u1 : fifo_rx port map(h, manchester_out, rd, wr, empty, full, fifo_out, word_used);
	--u1 : fifo port map(h, manchester_out, rd, wr, empty, full, fifo_out);
	u2 : decod_manchester port map (reg_16, manchester_out);
	u3 : detecteur_preambule port map (h, r, din_preambule, match, sfd);
	
	u4 : data_generator port map(h,r,plein,ecris,data);
	u5 : canal_tx port map(h,r,ecris,plein,rx,data);

	
	---- s�quenceur ----
	r1 <= not(e2) and not(e1) and not(e0);
	r2 <= not(sof) and not(e2) and not(e1) and e0;
	r3 <= sof and not(e2) and not(e1) and e0;
	r4 <= not(sfd)and not(e2) and e1 and not(e0);
	r5 <= sfd and not(e2) and e1 and not(e0);
	r6 <= not(e2) and e1 and e0;
	r7 <= e2 and not(e1) and not(e0);
	r8 <= not(c16equF) and e2 and not(e1) and e0;
	r9 <= c16equF and e2 and not(e1) and e0;
	r10 <= full and e2 and e1 and not(e0);
	r11 <= not(full) and e2 and e1 and not(e0);
	r12 <= eof and e2 and e1 and e0;
	r13 <= not(eof) and e2 and e1 and e0;
	
	process(h,r)
	begin
		if r = '1' then
			e0 <= '0'; e1 <= '0'; e2 <= '0';
			raz <= '0'; dec1 <= '0'; dec2 <= '0'; enable <= '0'; inc <= '0'; wr <= '0';
		elsif falling_edge(h) then
			e0 <= r1 or r2 or r5 or r7 or r8 or r11 or r13;
			e1 <= r3 or r4 or r5 or r8 or r9 or r10 or r11 or r13;
			e2 <= r6 or r7 or r9 or r10 or r11; 
			raz <= r1 or r13;
			dec1 <= r2 or r3 or r4 or r7 or r13;
			enable <= r3 or r4 ;
			dec2 <= r7 or r13;
			inc <= r6;
			wr <= r11;
		end if;
	end process;
	

	---- reg_in ----
	process (h,r,dec1)
	begin
		if r = '1' then
			reg_in <= (others => '0');
		elsif rising_edge(h) then
			if dec1 = '1' then
				reg_in <= Rx & reg_in(1455 downto 1);
			end if;
			
			if reg_in (1 downto 0) /= "00" then
				SOF <= '1';
				EOF <= '0';
			elsif 
				reg_in (2 downto 0) = "000" then
				EOF <= '1';
				SOF <= '0';
			else
				EOF <= '0';
				SOF <= '0';
			end if;
		end if;
	end process;
	
	-- =============================================
	---- C16 ----
	process(h,r,inc,raz)
	begin
		if r = '1' or raz = '1' then
			C16 <= (others => '0');
		elsif rising_edge(h)then
			if raz = '1' then
				C16 <= (others => '0');
			end if;
			if inc = '1' then
				C16 <= C16 + 1;
			else
				C16 <= C16;
			end if;
			
			if C16 = 15 then
				C16equF <= '1';	
			else
				C16equF <= '0';
			end if;
		end if;
	end process;
	
	---- reg_16 ----
	process(h,r,dec2)
	begin
		if r = '1' then
			reg_16 <= (others => '0');
		elsif rising_edge(h) then
			if dec2 = '1' then
				reg_16 <= din_reg16 & reg_16(15 downto 1);
			end if;
		end if;
		
	end process;
	
	---- Demux ----
	process(h,enable)
	begin
		if rising_edge(h) then
			if enable = '1' then
				din_preambule <= reg_in(0);
			else
				din_reg16 <= reg_in(0);
			end if;
		end if;
	end process;
	
end arch;	
	
	
		
	
				
				
				
				
				
				
				
				
				
				
			