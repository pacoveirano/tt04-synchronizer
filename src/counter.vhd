------------------------------------------------------------------
---- Package: Counter
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

package pk_counter is
  component counter is
    generic(
--      clk_freq_mhz                : integer  := 10;                    -- en MHz
--      time_ns                     : integer  := 1000;                  -- en ns
--      time_nbit                   : integer  := integer(ceil(real(time_ns*clk_freq_mhz/1000)));
--      nbit                        : integer  := integer(ceil(log2(real(time_ns*clk_freq_mhz/1000)))) 
      time_nbit                   : integer := 998;
      nbit                        : integer := 10
    );
    port(
      clk                         : in  std_logic;
      reset                       : in  std_logic;
      clear                       : in  std_logic;
      fin      		             : out std_logic
    );
  end component;
end pk_counter;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;

------------------------------------------------------------------
---- Entity: Counter
------------------------------------------------------------------
entity counter is
    generic(
--      clk_freq_mhz                : integer  := 10;                    -- en MHz
--      time_ns                     : integer  := 1000;                  -- en ns
--      time_nbit                   : integer  := integer(ceil(real(time_ns*clk_freq_mhz/1000)));
--      nbit                        : integer  := integer(ceil(log2(real(time_ns*clk_freq_mhz/1000)))) 
      time_nbit                   : integer := 998;
      nbit                        : integer := 10    
    );
    port(
      clk                         : in  std_logic;
      reset                       : in  std_logic;
      clear                       : in  std_logic;
      fin      		             : out std_logic
    );
end;

architecture rtl of counter is



   signal s_fin            	                               : std_logic;
   signal count                    			                   : std_logic_vector(nbit-1 downto 0);  
   signal count_FF                			                   : std_logic_vector(nbit-1 downto 0);  
   type STATE_TYPE IS (s0,s1,s2);
   signal STATE, NEXTSTATE : STATE_TYPE;
   
begin
    
combin: process(reset, clear, STATE, count_FF)
  begin
     case STATE is 
         when s1 =>
            s_fin <= '0';
            if clear = '0' then 
               NEXTSTATE <= s2;
               count <= (others => '0');
            else 
               NEXTSTATE <= s1;
               count <= (others => '0');
            end if;
         when s2 =>
            if clear = '0' then 
               if count_FF = time_nbit then  
                  NEXTSTATE <= s1;
                  count <= count_FF + 1;
                  s_fin <= '1';
               else
                  NEXTSTATE <= s2;
                  count <= count_FF + 1;   
                  s_fin <= '0';                  
               end if; 
            else 
               s_fin <= '0';
               NEXTSTATE <= s1;
               count <= (others => '0');
            end if;
          when others => 
            NEXTSTATE <= s1;
            count <= (others => '0');
            s_fin <= '0';
      end case;
end process;
        
 
sync:  process(clk, reset, count, STATE, NEXTSTATE)
  begin
	if (reset = '1') then
		count_FF <= (others => '0');
		STATE <= s1;
		fin <= '0';
	elsif(clk'event and clk = '1') then
		STATE <= NEXTSTATE;
		count_FF <= count; 
		fin <= s_fin;
	end if;
end process;
	

end rtl;
