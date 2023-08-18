library ieee;
use ieee.std_logic_1164.all;
library work;
--use work.pk_counter.all;
use std.env.finish;

entity counter_tb is
end;

architecture BEHAV of counter_tb is
signal clk              : std_logic := '0';
signal reset            : std_logic;
signal clear            : std_logic;
signal fin              : std_logic;    
constant T_clk      : time := 100 ns;

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

begin


         counter_inst: counter 
        generic map(
           time_nbit  => 998,
           nbit  => 10  
            ) 
        port map (
           clk      => clk,
           reset    => reset,
           clear    => clear,
           fin      => fin);

    reset <= '1', '0' after 3.2*T_clk/2;

           -- clock
      clk_process: process
      begin
         clk<= '1';    
         wait for (T_clk/2); 
         clk<= '0'; 
         wait for (T_clk/2); 
      end process;
     


    stimulus:
    process 
    variable v_time     : time := 0 ns;
    begin       
        -- signals idle
        clear <= '1';
        wait for 500 ns;
        clear <= '0';
        v_time:= now;
        -- wait fin
        wait until fin = '1';
        v_time:= now - v_time;
        report "Tiempo medido =" & time'image(v_time);
        -- wait some periods and delay
        wait for (2*T_clk);
        assert false report "Test finish" severity failure;
    end process;
    
end BEHAV;

