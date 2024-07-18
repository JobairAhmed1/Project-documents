----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2024 08:18:17 PM
-- Design Name: 
-- Module Name: servo_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity servo_test is
  Port ( 
    btn1         : in    STD_LOGIC;
    btn2         : in    STD_LOGIC;
    clk          : in    STD_LOGIC;
    led1         : out   STD_LOGIC;
    mtr1         : out   STD_LOGIC
  
  
  
  
  );
end servo_test;

 architecture Behavioral of servo_test is

 signal count : integer range 0 to 1200000;
 signal var : integer range 0 to 2500000:=250000;
 signal pwm : std_logic;
 
    signal hz1   : std_logic:='1';
    signal hz1_last   : std_logic:='0';
    
 
  begin

  edge_det_process : process(clk)
    begin
    if rising_edge(clk) then
        hz1_last <= hz1;
    end if;
   end process edge_det_process;
   
   mtr_control: process(clk)
   begin
   if rising_edge(clk) then
   if btn1 = '1' then
   var <= 2000000;
   elsif btn2 = '1' then
   var <= 500000;
   end if;
--   if btn1 = '1' and hz1='1' and hz1_last ='0' then
--   var <= var + 250000;
--        if var >= 2500000 then
--        var <= 2500000;
--        end if;
--   elsif btn2 = '1' and hz1='1' and hz1_last ='0' then
--   var <= var - 250000;
--        if var <= 0 then
--        var <= 0;
--        end if;
--   end if;
   end if;
   
   end process;
   
   slow_clk: process(clk)
   variable count: integer:=0;
   begin
   
   if rising_edge (clk) then
        count := count+1;
        if count = var then
            pwm <= '1';
        elsif count =2500000 then
            pwm <= '0';
            count := 0;
        end if;
   end if;
   end process;
   
   pwm_out : process(clk)
   begin
   if rising_edge (clk)then
        if pwm = '1' then
            led1 <='1';
            mtr1 <='1';
        else
            led1 <='0';
            mtr1 <='0';
        end if;
    end if;
    
    end process;
    

   


end Behavioral;
