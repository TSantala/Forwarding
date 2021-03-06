library ieee;
use ieee.std_logic_1164.all;
library work;
Use work.all;
use ieee.numeric_std.all;

entity one_buffer is
	port (
		clk, enable_0, enable_1, enable_2, enable_3, write_out: in std_logic;
		w: in std_logic_vector(7 downto 0); -- input data
		lngth_in: in std_logic_vector (15 downto 0); -- know how long to send data before switching ports...think about this
		valid, reading: out std_logic; -- do we have at least one valid address in here
		lngth_out: out std_logic_vector (15 downto 0);
		output: out std_logic_vector (7 downto 0) -- out one byte at a time
		); 
end one_buffer;

architecture segment of one_buffer is
	type state_type is
		(A, B, C, D); -- reset, waiting, reading, writing
	signal state_reg, state_next: state_type;
	buffer lngth_all: std_logic_vector(367 downto 0); --smallest frame size is 64B*8 = 512 bits, 23 of these can fit in the hold buffer at a time, 23*6 = 368
	buffer hold: 	std_logic_vector(12143 downto 0); 
	variable amt, place:	integer
begin
	process (clk, reset) --state register update
	begin
		if (reset = '1') then state_reg <= A;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
	
	process(lngth_all)
	begin
		lngth_out <= lngth_all(367 downto 352);
	end process;
	
	process(hold)
	begin
		output <= hold(12143 downto 12136);
	end process;
	
	process(amt)
	begin
		for i in 22 downto 0 loop
			if (to_integer(unsigned(lngth_all((i*16 + 15) downto (i*16)))) > 0) then
				amt<= amt + to_integer(unsigned(lngth_all((i*8 + 7) downto (i*8)))) + 16;
			else
				place <= i*16 + 15;
			end if;
		end loop;
	end process;
	
	process(state_reg, enable_0, enable_1, enable_2, write_out, lngth_in)
	begin
	case state_reg is
	when A => -- reset state, all zero
		valid <= '0';
		reading <= '0';
		lngth_all(367 downto 0) <= '0';
		hold (12143 downto 0) <= '0';
		state_next <= B; -- go immediately to B after all reset
	when B => -- waiting state
		reading <= '0';-- update reading bit (0)
		if (enable_0 and not enable_1 and not enable_2 and not enable_3) then
			state_next <= C;-- go to C if enable_0 asserted and enable_1/2/3 all not asserted
		else if (write_out) then
			state_next <= D;-- go to D if write_out asserted 
		else
			state_next <= B;-- else, stay in B
		end if;
	when C => --reading state
		if (to_integer(unsigned(lngth_in)) + 16 + amt < 1518) then-- check if you have enough space in the hold buffer (be updating this...)
			reading <= '1';-- update reading bit
		-- read in new length value
		-- read in packet for appropriate number of cycles
		-- update space counter
		-- update valid bit for writing out
		
		--AFTER READING--
		
		-- go to D if write_out asserted
		-- stay in C if enable_0 asserted and enable 1/2/3 all not asserted
		-- else go to B
	when D
		-- update reading bit
		-- use length in MSB position of lngth_all to determine how many cycles to go
		-- shift hold buffer for appropriate number of cycles
		-- update space counter
		-- check if you need to update valid bit
		-- shift out length from lngth_all
		
		--AFTER WRITING--
		
		-- go to C if enable_0 asserted and enable 1/2/3 all not asserted
		-- stay in D if write_out asserted (shouldn't really ever be the case)
		-- else go to B
	end process;
end segment; 