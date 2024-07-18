library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Hz_Controller is
    Port (
        switch_input : in    STD_LOGIC;
        btn1         : in    STD_LOGIC;
        btn2         : in    STD_LOGIC;
        btn3         : in    STD_LOGIC;
        btn4         : in    STD_LOGIC;
        
        clk          : in    STD_LOGIC;
        led1         : out   STD_LOGIC;
		led2         : out   STD_LOGIC;
		led3         : out   STD_LOGIC;
		led4         : out   STD_LOGIC
    );
end Hz_Controller;

architecture Behavioral of Hz_Controller is

    signal count : integer range 0 to 12000000;
--    signal count1: integer range 0 to 12000000;
	signal count2: integer range 0 to 12000000;
--    signal count3: integer range 0 to 12000000;
    signal count4: integer range 0 to 12000000;

    signal x     : integer range 0 to 24000 := 20000;

    signal one_hz   : std_logic;
	signal two_hz   : std_logic;
	signal four_hz  : std_logic;
	signal eight_hz : std_logic;
	signal hz1      : std_logic:='0';
	signal hz1_last : std_logic:='1';
	signal mem      : integer range  0 to 24000 := 20000;

begin

   edge_det_process : process(clk)
    begin
    if rising_edge(clk) then
        hz1_last <= hz1;
    end if;
   end process edge_det_process;
   

    slow_clk_gen: process(clk)
	variable counter: integer:= 12000000;

	variable y: integer:= 0;
	
    begin
        if rising_edge(clk) then 
            count  <= count  + 1;
            count2 <= count  + 1;
			count4 <= count4 + 1;
            
 
            
			if count = x then
			    one_hz <= '1';
			elsif count = 24000 then
			    one_hz <= '0';
				count <= 0;
			end if;
			
			if count = mem then
			    two_hz <= '1';
			elsif count = 24000 then
			    two_hz <= '0';
				count <= 0;
			end if;
			
						
		    if count4 = 600000 then
			    hz1 <= '1';
			elsif count4 = 1200000 then
			    hz1 <= '0';
				count4 <= 0;
			end if;
 
        end if;
    end process;
    ---------------------------------------------------------------------
   led_level: process(clk)
   begin
   if rising_edge(clk) then
   if btn1 = '1' and x < 24000 and hz1 = '1' and hz1_last = '0' then 
   x <=x+100;
   end if;
   
   if btn2 = '1' and x > 100 and  hz1 = '1' and hz1_last = '0' then 
   x <=x-100;
   end if;
   end if;
   end process;
   
   --saves the brightness value when btn3 is pressed while the led's are on.
   --btn 4 resets the brigness level to dark
   --probably this can be scaled to save array of values and reset the array
   
  memory_test: process(clk)
  begin
  if rising_edge(clk)then
  if switch_input ='1' and btn3 ='1' then
  mem <= x;
  elsif btn4 ='1' then
  mem <= 23999;
  end if;
  
  
  end if;
  end process;
--------------------------------------------------------------------------------
    led_test: process(clk)
    begin
    if rising_edge(clk) then
    if switch_input = '1' then
    if one_hz = '1' then
        led1 <= '1';
        led2 <= '1';
        led3 <= '1';
        led4 <= '1';
    elsif one_hz = '0' then
        led1 <= '0';
        led2 <= '0';
        led3 <= '0';
        led4 <= '0';
     else
        led1 <= '0';
        led2 <= '0';
        led3 <= '0';
        led4 <= '0';
    end if;
    end if;
    
    if btn3 = '1' and switch_input ='0' then
    if two_hz = '1' then
        led1 <= '1';
        led2 <= '1';
        led3 <= '1';
        led4 <= '1';
    elsif two_hz = '0' then
        led1 <= '0';
        led2 <= '0';
        led3 <= '0';
        led4 <= '0';
     else
        led1 <= '0';
        led2 <= '0';
        led3 <= '0';
        led4 <= '0';
    end if;
    end if;
--		
       
	 end if;
    end process;

end Behavioral;
