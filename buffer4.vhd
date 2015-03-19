library ieee;
use ieee.std_logic_1164.all;
library work;
Use work.all;
use ieee.numeric_std.all;

entity buffer4 is
	port (
		clk, enable, reset: in std_logic;
		portOne,portTwo, portThree, portFour: in std_logic_vector (7 downto 0); -- one byte at time for all inputs
		lngth_in: in std_logic_vector (15 downto 0); -- know how long to send data before switching ports...think about this
		output: out std_logic_vector (7 downto 0); -- out one byte at a time
		portNum: out std_logic_vector(2 downto 0) -- port number to send to table
		); 
end buffer4;

architecture selector of buffer4 is 
	type state_type is
		(A, B, C, D, E);
	signal state_reg, state_next: state_type;
	signal current_length : std_logic_vector(15 downto 0);
begin
	process (clk, enable, reset) --state register update
	begin
		if (reset = '1' or enable = '0') then state_reg <= A;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg, enable, lngth_in, portOne, portTwo, portThree, portFour)
	begin
		case state_reg is
		when A => -- reset state, wait for enable
			portNum <= "000";
			if (enable = '1') then
				state_next <= B;
			else
				state_next <= A;
			end if;
		when B => --port one
			portNum <= "001";
			output <= portOne;
			current_length <= std_logic_vector( unsigned(current_length) + 1 );
			if (current_length = lngth_in) then
				state_next <= C;
				current_length <= "0000000000000000";
			else
				state_next <= B;
			end if;
		when C => --port two
			portNum <= "010";
			output <= portTwo;
			current_length <= std_logic_vector( unsigned(current_length) + 1 );
			if (current_length = lngth_in) then
				state_next <= D;
				current_length <= "0000000000000000";
			else
				state_next <= C;
			end if;
		when D => --port three
			portNum <= "011";
			output <= portThree;
			current_length <= std_logic_vector( unsigned(current_length) + 1 );
			if (current_length = lngth_in) then
				state_next <= E;
				current_length <= "0000000000000000";
			else
				state_next <= D;
			end if;
		when E => --port four
			portNum <= "100";
			output <= portFour;
			current_length <= std_logic_vector( unsigned(current_length) + 1 );
			if (current_length = lngth_in) then
				state_next <= B;
				current_length <= "0000000000000000";
			else
				state_next <= E;
			end if;
		end case;
	end process;
end selector;