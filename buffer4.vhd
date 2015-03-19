library ieee;
use ieee.std_logic_1164.all;
library work;
Use work.all;
use ieee.numeric_std.all;

entity buffer4 is
	port (
		clk, enable, reset: in std_logic;
		portOne,portTwo, portThree, portFour: in std_logic_vector (7 downto 0); -- one byte at time for all inputs
		lngth_one, lngth_two, lngth_three, lngth_four: in std_logic_vector (15 downto 0); -- know how long to send data before switching ports...think about this
		output: out std_logic_vector (7 downto 0); -- out one byte at a time
		state_debug: out std_logic_vector(2 downto 0);
		count_out: out integer;
		transition_out: out std_logic;
		portNum: out std_logic_vector(2 downto 0) -- port number to send to table
		); 
end buffer4;

-- OUTPUT_VALID to flag when we're in transition or not?

architecture selector of buffer4 is 
	type state_type is
		(A, B, C, D, E);
	signal state_reg, state_next: state_type;
	signal current_length : integer;
	signal transition : std_logic;
begin
	process (clk, enable, reset) --state register update
	begin
		if (reset = '1' or enable = '0') then state_reg <= A;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
			if (transition = '1') then
				current_length <= 0;
			else
				current_length <= current_length + 1;
			end if;
		end if;
	end process;
	
	process(transition, current_length)
	begin
		transition_out <= transition;
		count_out <= current_length;
	end process;
	
	process(state_reg, enable, current_length, lngth_one, lngth_two, lngth_three, lngth_four, portOne, portTwo, portThree, portFour)
	begin
		case state_reg is
		when A => -- reset state, wait for enable
			portNum <= "000";
			state_debug <= "000";
			output <= "00000000";
			transition <= '1';
			if (enable = '1') then
				state_next <= B;
			else
				state_next <= A;
			end if;
		when B => --port one
			portNum <= "001";
			state_debug <= "001";
			output <= portOne;
			--current_length <= ( unsigned(current_length) + 1 );
			if (current_length = to_integer(unsigned(lngth_one)) + 18) then		-- +18 for non-data overhead
				state_next <= C;
				transition <= '1';
				--current_length <= "0000000000000000";
			else
				state_next <= B;
				transition <= '0';
			end if;
		when C => --port two
			portNum <= "010";
			state_debug <= "010";
			output <= portTwo;
			--current_length <= ( unsigned(current_length) + 1 );
			if (current_length = to_integer(unsigned(lngth_two)) + 18) then
				state_next <= D;
				transition <= '1';
				--current_length <= "0000000000000000";
			else
				state_next <= C;
				transition <= '0';
			end if;
		when D => --port three
			portNum <= "011";
			state_debug <= "011";
			output <= portThree;
			--current_length <= ( unsigned(current_length) + 1 );
			if (current_length = to_integer(unsigned(lngth_three)) + 18) then
				state_next <= E;
				transition <= '1';
				--current_length <= "0000000000000000";
			else
				state_next <= D;
				transition <= '0';
			end if;
		when E => --port four
			portNum <= "100";
			state_debug <= "100";
			output <= portFour;
			--current_length <= ( unsigned(current_length) + 1 );
			if (current_length = to_integer(unsigned(lngth_four)) + 18) then
				state_next <= B;
				transition <= '1';
				--current_length <= "0000000000000000";
			else
				state_next <= E;
				transition <= '0';
			end if;
		end case;
	end process;
end selector;