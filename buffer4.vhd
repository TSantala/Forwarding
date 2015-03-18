library ieee;
use ieee.std_logic_1164.all;
library work;
Use work.all;
use ieee.numeric_std.all;

entity buffer4 is
	port (
		clk, enable: in std_logic;
		portOne,portTwo, portThree, portFour: in std_logic_vector (7 downto 0); -- one byte at time for all inputs
		lngth_in: in std_logic_vector (15 downto 0); -- know how long to send data before switching ports...think about this
		output: out std_logic_vector (7 downto 0) -- out one byte at a time
		portNum: out std_logic_vector(2 downto 0) -- port number to send to table
		); 
end buffer4;

architecture selector of buffer4 is 
	type state_type is
		(A, B, C, D, E);
	signal state_reg, state_next: state_type;
begin
	process (clk, enable, reset) --state register update
	begin
		if (reset = '1' or enable = '0') then state_reg <= A;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg, enable, lngth_in, portOne, portTwo, portThree, portFour);
	begin
		case state_reg is
		when A => -- reset state, wait for enable
			portNum <= "000";
			if (enable = '1') then
				state_next <= B;
			else
				state_next <= A;
		when B => --port one
			portNum <= "001";
			for i in 0 to (to_integer(lngth_in) +17) loop
				output <= portOne;
				wait for 10 ns; -- wait for one clock cycle each time
			end loop;
			state_next <= C;
		when C => --port two
			portNum <= "010";
			for i in 0 to (to_integer(lngth_in) +17) loop
				output <= portTwo;
				wait for 10 ns; -- wait for one clock cycle each time
			end loop;
			state_next <= D;
		when B => --port three
			portNum <= "011";
			for i in 0 to (to_integer(lngth_in) +17) loop
				output <= portThree;
				wait for 10 ns; -- wait for one clock cycle each time
			end loop;
			state_next <= E;
		when E => --port four
			portNum <= "100";
			for i in 0 to (to_integer(lngth_in) +17) loop
				output <= portFour;
				wait for 10 ns; -- wait for one clock cycle each time
			end loop;
			state_next <= B;
		end case;
	end process;
end selector;