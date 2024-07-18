library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem is
    Port (
       
--        btn1         : in    STD_LOGIC;
--        btn2         : in    STD_LOGIC;
--        btn3         : in    STD_LOGIC;
        led_act      : in    std_logic;
        current_bit  : in    STD_LOGIC;
		mem_btn 	 : in 	 STD_LOGIC;
        clk          : in    STD_LOGIC;
--      led1         : out   STD_LOGIC;
--		led2         : out   STD_LOGIC;
--		led3         : out   STD_LOGIC;
		led1         : out   STD_LOGIC
    );
end mem;

architecture Behavioral of mem is
-- DEFINE SIGNALS--
    signal slow_clk: std_logic :='0';
    signal slow_clk_last: std_logic;
    signal counter : unsigned(26 downto 0) := (others => '0');
	signal mem :unsigned(127 downto 0) := (others => '0') ;
	
--    signal current_bit: std_logic; 
--    memory(row)(col)<= current_bit;

	
	

begin
---------------------------------------------------------------


   edge_det_process : process(clk)
    begin
    if rising_edge(clk) then
        slow_clk_last <= slow_clk;
    end if;
   end process edge_det_process;


--fast -> slow clock---
slow_clk_gen: process(clk)
--define variable signals. example : variable i     : integer := 0; 

begin
    if rising_edge(clk) then
        if counter = (15624999) then
            slow_clk <= '1';
            counter <= (others => '0');
        else
            slow_clk <= '0';
            counter <= counter + 1;
        end if;
    end if;
end process;
--------------------------------------------------------------
--RAM TEST-----------------------------------------------------
ram_process: process(clk)
variable x: integer:=0;
begin
    if rising_edge(clk) then
        if mem_btn = '1' then
            mem(x) <= current_bit;  -- Write to memory regardless of x
			
            if(slow_clk = '1' and slow_clk_last = '0') then
                x := x + 1;
            if x = 128 then
                x := 0;  -- Reset x only after writing to mem(15)
            end if;
			end if;
        end if;
    end if;
end process;

      --
      
led_activation:process(clk)
variable y: integer:=0;
begin
  if rising_edge(clk)then
    if (led_act = '1') then
        if mem(y) = '1' then
        led1 <= '1';        
     elsif mem(y) ='0' then
        led1 <= '0';
        end if;
   if(slow_clk = '1' and slow_clk_last = '0') then
       y:=y+1;
     if (y=128) then
       y:=0;
     end if;

   end if;
   else 
       led1 <='0';
	   y:=0;
  end if;--led_act
end if;--rising edge

end process;
end Behavioral;
