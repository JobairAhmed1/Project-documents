library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
--use IEEE.math_real

library UNISIM;
use UNISIM.VComponents.all;

entity Lab5 is
    Port ( sys_clk : in std_logic;
          reset_btn   : in std_logic;
          reset_btn1  : in std_logic;
          btn1 : in std_logic;
          btn2 : in std_logic;
          btn3 : in std_logic;
          TMDS, TMDSB : out std_logic_vector(3 downto 0));
end Lab5;

architecture Behavioral of Lab5 is

-- Video Timing Parameters
--1280x720@60HZ
constant HPIXELS_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(1280, 11)); --Horizontal Live Pixels
constant VLINES_HDTV720P  : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(720, 11));  --Vertical Live ines
constant HSYNCPW_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(80, 11));  --HSYNC Pulse Width
constant VSYNCPW_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(5, 11));    --VSYNC Pulse Width
constant HFNPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(72, 11));   --Horizontal Front Porch
constant VFNPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(3, 11));    --Vertical Front Porch
constant HBKPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(216, 11));  --Horizontal Front Porch
constant VBKPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(22, 11));   --Vertical Front Porch

constant pclk_M : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(36, 8));
constant pclk_D : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(24, 8)); 

--Morning Red
constant COLOR1_RED : std_logic_vector(7 downto 0) := x"FF";
constant COLOR1_GREEN : std_logic_vector(7 downto 0) := x"6A"; 
constant COLOR1_BLUE : std_logic_vector(7 downto 0) := x"00";  
 
--plum
constant COLOR2_RED : std_logic_vector(7 downto 0) := x"DD";
constant COLOR2_GREEN : std_logic_vector(7 downto 0) := x"A0";
constant COLOR2_BLUE : std_logic_vector(7 downto 0) := x"DD"; 
 
--sgi salmon
constant COLOR3_RED : std_logic_vector(7 downto 0) := x"C6";
constant COLOR3_GREEN : std_logic_vector(7 downto 0) := x"71";
constant COLOR3_BLUE : std_logic_vector(7 downto 0) := x"71";
     
--burnt sienna
constant COLOR4_RED : std_logic_vector(7 downto 0) := x"8A";
constant COLOR4_GREEN : std_logic_vector(7 downto 0) := x"36";
constant COLOR4_BLUE : std_logic_vector(7 downto 0) := x"0F";


constant tc_hsblnk: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1);
constant tc_hssync: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1 + HFNPRCH_HDTV720P);
constant tc_hesync: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P);
constant tc_heblnk: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P + HBKPRCH_HDTV720P);
constant tc_vsblnk: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1);
constant tc_vssync: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1 + VFNPRCH_HDTV720P);
constant tc_vesync: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P);
constant tc_veblnk: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P + VBKPRCH_HDTV720P);
signal sws_clk: std_logic_vector(3 downto 0); --clk synchronous output
signal sws_clk_sync: std_logic_vector(3 downto 0); --clk synchronous output
signal bgnd_hblnk : std_logic;
signal bgnd_vblnk : std_logic;


signal red_data, green_data, blue_data : std_logic_vector(7 downto 0) := (others => '0');
signal hcount, vcount : std_logic_vector(10 downto 0);
signal hsync, vsync, active : std_logic;
signal pclk : std_logic;
signal clkfb : std_logic;
signal rgb_data : std_logic_vector(23 downto 0) := (others => '0');

signal counter : unsigned(26 downto 0) := (others => '0');
signal slow_clk : std_logic;


type state_type is (COLOR1, COLOR2, COLOR3, COLOR4,COLOR5,COLOR6, COLOR7, COLOR8, COLOR9,COLOR10);
signal state : state_type := COLOR1;


signal horiz : integer range 0 to 1300;
signal vert : integer range 0 to 800;

begin

horiz <= TO_INTEGER(unsigned(hcount));
vert <= TO_INTEGER(unsigned(vcount));


--horiz <= unsigned(to_integer(hcount)); 

pixel_clock_gen : entity work.pxl_clk_gen port map (
    clk_in1 => sys_clk,
    clk_out1 => pclk,
    locked => open,
    reset => '0'
);

timing_inst : entity work.timing port map (
	tc_hsblnk=>tc_hsblnk, --input
	tc_hssync=>tc_hssync, --input
	tc_hesync=>tc_hesync, --input
	tc_heblnk=>tc_heblnk, --input
	hcount=>hcount, --output
	hsync=>hsync, --output
	hblnk=>bgnd_hblnk, --output
	tc_vsblnk=>tc_vsblnk, --input
	tc_vssync=>tc_vssync, --input
	tc_vesync=>tc_vesync, --input
	tc_veblnk=>tc_veblnk, --input
	vcount=>vcount, --output
	vsync=>vsync, --output
	vblnk=>bgnd_vblnk, --output
	restart=>reset_btn,
	clk=>pclk);
	
hdmi_controller : entity work.rgb2dvi 
    generic map (
        kClkRange => 2
    )
    port map (
        TMDS_Clk_p => TMDS(3),
        TMDS_Clk_n => TMDSB(3),
        TMDS_Data_p => TMDS(2 downto 0),
        TMDS_Data_n => TMDSB(2 downto 0),
        aRst => '0',
        aRst_n => '1',
        vid_pData => rgb_data,
        vid_pVDE => active,
        vid_pHSync => hsync,
        vid_pVSync => vsync,
        PixelClk => pclk, 
        SerialClk => '0');
        
        
active <= not(bgnd_hblnk) and not(bgnd_vblnk); 
rgb_data <= red_data & green_data & blue_data;	 




slow_clk_gen : process(pclk) 
begin
	if rising_edge(pclk) then
		if counter = (74250000)/10 - 1 then
			slow_clk <= '1';
			counter <= (others => '0');
		else
			slow_clk <= '0';
			counter <= counter + 1;
		end if;
	end if;
end process slow_clk_gen;



--begin     

state_proc : process(hcount, vcount, state, pclk,horiz,vert)
variable i     : integer := 0; 
variable v     : integer ;
variable j     : integer := 0;
variable jj    : integer := 0;
variable jj1   : integer := 0;
variable jj2   : integer := 0;
variable sumjj : integer := 0;
variable jump  : integer := 0;
variable wind  : integer;
variable c,ct  : integer := 0;
variable speed : integer := 0;
variable fall  : integer := 0;
variable cloud1 : integer := 0;
variable cloud2 : integer := 0;
variable cloud3 : integer := 0;
variable jt     : integer := 0;
variable g_o    : integer := 0;








--variable x: integer;
--variable y: integer;
begin
    if rising_edge(pclk) then
--    i <= 0;
             if slow_clk = '1' then
             --------------------Ammount of times clock refreshed in 10 seconds-------------------
                if i<=60 then    
                   i := i+1 ;
				 elsif i >=61 then				  
				  i := 0;
                 end if;	
                 -------------for moving sun-------------------			 
				 if i <=30 then 
				    v := -(i*21);					
				 else
				
				    v :=  (i*21)-1250;
					
				 end if;
                ------------for moving clouds--------------------------------------------
				if cloud1 >= 1300 then
				cloud1 := 0;
				
				end if;
				if cloud2 >= 1280 then
				cloud2 := 0;
				end if;
				
                cloud1 := cloud1 + 5;

				cloud2 := cloud2 +10;
				
				cloud3 := cloud3+7;
				 --------------------------------------------------------------------------
				 -----------------------ending courtains---------------------------------------------------
				 if g_o >= 1 and ct <= 720 then
				     ct:= ct+36;
				 elsif g_o <= 0 and ct >= 0 then
				     ct:= ct - 36;
				 end if;
				 
				  if reset_btn1 = '1' then
				  g_o := 0; 
				  end if;
				  
				  if reset_btn1 = '1' then 
				    g_o := 0;
					j := 0;
				 end if;
				 
				 -----------------------------------world border------------------------------------------
				 if j<=0 then 
				  j:=0;
				 elsif j>=1200 then
				  j:=1200;
				 end if;
				 --------------------------------------------------------------------------------------------
				 ----------------------------FOR Platforming--------------------------------------------------
				 if j>=400 and  j<=550 then
				    if jump>=50 then
				     jj:= 50;
				    end if;
					
				 elsif j>=600 and  j<=750 then
				    jj:= 0;
				    if jump>=90 then
				     jj1:= 90;
				    end if;
				elsif j>=900 and  j<=1000 then
				    jj1:= 0;
				    if jump>=70 then
				     jj2:= 70;
				    end if;
				 elsif jump <= 0 then
				    jj:=0;
					jj1:=0;
					jj2:=0;
				 end if;
				 ----------------------------------------------------------------------------------------------------
				 ------------------------penalty zone----------------------------------------------------------------
				 if j<= 445 and j >= 350 and jump <= 0  then 
				     g_o := 1;
				     if j >=10 then
				      j:=0;
					 end if;
					 
				 elsif  j<= 900 and j >= 800 and jump <= 0  then 
				     g_o := 1;
					 if j >=10 then
				      j:=0;				  
					 end if;
					 
				elsif  j<= 1300 and j >= 1200 and jump <= 0  then 
				     g_o := 3;
					 if j >=10 then
				      j:=0;
					 
					 end if;
					  
				 end if;
				 
				 
				 ---preventing getting into an area without condition--------
				if j>= 400 and  j<= 550 and (jump >= 50 or jj >= 50) then
				j:=j;
				elsif j>= 400 and j<= 450 and  (jump <= 50 or jj <= 50)  then
				j:= 399;
				elsif j<= 550 and j>= 500 and  (jump <= 50 or jj <= 50)  then
				j:= 551;
				else 
				j:=j;
				end if;
				
				
				if j>= 600 and  j<= 800 and (jump >= 90 or jj1 >= 90) then
				j:=j;
				elsif j>= 600 and j<= 650 and  (jump <= 90 or jj1 <= 90)  then
				j:= 599;
				elsif j<= 800 and j>= 750 and  (jump <= 90 or jj1 <= 90)  then
				j:= 801;
				else 
				j:=j;
				end if;
				
				if j>= 900 and  j<= 1000 and   (jump >= 70 or jj2 >= 70) then
				j:=j;
				elsif j>= 900 and j<= 950 and  (jump >= 70 or jj2 >= 70)  then
				j:= 899;
				elsif j<= 1000 and j>= 950 and  (jump >= 70 or jj2 >= 70)  then
				j:= 1001;
				else 
				j:=j;
				end if;
				    

				 
				 -------------------------------------------------------------------------------------------------------
				 ---------for player movement -----------------------------------------------------------------------
				 if btn1 = '1' or btn2 = '1' then
				     
				      speed := speed + 1; 
					  
                 else 
				      speed := 0;	  -----x= y^2 if x< 8
				 
				 end if;
				 
				 if btn1 = '1' then
				     
				    j :=j+ (speed)**2;  -----x= y^2 if x< 8
					  if SPEED >= 4 then 
                         SPEED:= 4;
					  end if;
				 end if;
				 
				 
				 if btn2 = '1' then
				    j := J-(speed)**2;	
                      if SPEED >= 4 then 
                         SPEED:= 4;
					  end if;
				 end if;
				 -------------------------------------------------------------------------------------
				 ------------------Jumping---------------------------------------------------------------------------
				 if jump<=0 then
				    jt := 0;
				end if;
				
				 jt := jt+1;
				 
				 
				 if btn3 = '1' and jump<= 100 and jt <= 20 then
				    jump := jump+10;
					
				 else
				   if jump >= 0 then
				      jump := jump -15;
					 if jump <= 0 then
					    jump :=0;
						
					end if;
					
					end if;
				 end if;
				 

				 if (i <= 10) or (i >= 20 and i <=29) or (i >= 40 and i <=49 )then
				    c:= c+1;
				 else 
				    c:=c-1;
				 end if;
				 wind := c-5;


              else ------------------------------------------------------------------------------------------------------------------------------------------
              ----------------------------------------------World Drawing------------------------------------------------------------------
			
			  

                --Morning sun
                 if (horiz-(i*21)+100)**2+(vert-(v+600))**2 <= 2000   then 
                    red_data   <= x"FF";
                    blue_data  <= x"6A";
                    green_data <= x"3c";
					
				 -----------------------------------------------------------------------can copy paste
                 else
                 --background color ccff99 or ffcc99
                    red_data    <= x"ff";
                    blue_data   <= x"cc";
                    green_data  <= x"99";
                 end if;
              
              
                 if  vert >= 600  then 
                    red_data   <= x"00";
                    blue_data  <= x"cc";
                    green_data <= x"00";
			  ----------------------------------clouds---------------------------------------------------------------
				elsif vert >= 100 and vert<= 140 and horiz >= 0+cloud1 and horiz <= 40+cloud1 then 
				----- #eef4f4
				    red_data    <= x"ee";
                    blue_data   <= x"f4";
                    green_data  <= x"f4";
					
				elsif vert >= 80 and vert<= 140 and horiz >= 40+cloud1 and horiz <= 100+cloud1 then 
				----- #eef4f4
				    red_data    <= x"ee";
                    blue_data   <= x"f4";
                    green_data  <= x"f4";
					
				elsif vert >= 100 and vert<= 140 and horiz >= 100+cloud1 and horiz <= 140+cloud1 then 
				----- #eef4f4
				    red_data    <= x"ee";
                    blue_data   <= x"f4";
                    green_data  <= x"f4";
					------------------------------------------------------------------------------------------
				elsif vert >= 100+50 and vert<= 140+30 and horiz >= 0+cloud2 and horiz <= 60+cloud2 then 
				----- #eef4f4
				    red_data    <= x"ee";
                    blue_data   <= x"f4";
                    green_data  <= x"f4";
					
				elsif vert >= 80+50 and vert<= 140+30 and horiz >= 60+cloud2 and horiz <= 140+cloud2 then 
				----- #eef4f4
				    red_data    <= x"ee";
                    blue_data   <= x"f4";
                    green_data  <= x"f4";
					
				elsif vert >= 100+50 and vert<= 140+30 and horiz >= 100+cloud2 and horiz <= 190+cloud2 then 
				----- #eef4f4
				    red_data    <= x"ee";
                    blue_data   <= x"f4";
                    green_data  <= x"f4";
                
				 end if;
             
             --Landscape--946f6a
                 if  vert >= 710  then 
                    red_data   <= x"94";
                    blue_data  <= x"6f";
                    green_data <= x"6a";

                 end if;
	-------------------------------------------------------------------------------------------------------------------------
				 if (vert <=450 and vert >=375 and horiz <=400 and horiz>=120) then --TreeL1.1------
				 --#2a6646
				    red_data   <= x"2a";
                    blue_data  <= x"66";
                    green_data <= x"46";
					
				 elsif (vert <=480 and vert >=420 and horiz <=150 and horiz>=50) then --TreeL1.2------
				 --#2a6646
				    red_data   <= x"2a";
                    blue_data  <= x"66";
                    green_data <= x"46";
					
				 elsif (vert <=480 and vert >=420 and horiz <=440 and horiz>=340) then --TreeL1.3------
				--#2a6646
				    red_data   <= x"2a";
                    blue_data  <= x"66";
                    green_data <= x"46";
					
				 elsif (vert <=600 and vert >=400 and horiz <=300 and horiz>=240) then --TreeTrunk1------
				 --#cc9f56
				    red_data   <= x"cc";
                    blue_data  <= x"9f";
                    green_data <= x"56";
					
				-----------------------------------------------------------------------------------------------------------------------------------
				
						
				 elsif (horiz-1025 >=-vert +340+2*wind and -horiz+1025 >=-vert +340-wind and vert <=440 ) then  --TreeL2.1-----
				
				 --#2a6646
				    red_data   <= x"2a";
                    blue_data  <= x"66";
                    green_data <= x"46";
				
				 elsif (vert-1025 >=-horiz +280+2*wind and vert+1025 >=horiz +280-wind and vert <=400 ) then  --TreeL2.2-----
				
				 --#2a6646
				    red_data   <= x"2a";
                    blue_data  <= x"66";
                    green_data <= x"46";
				
				 elsif (vert-1025 >=-horiz +220+2*wind and vert+1025 >=horiz +220-wind and vert <=340 ) then  --TreeL2.3-----
				
				 --#2a6646
				    red_data   <= x"2a";
                    blue_data  <= x"66";
                    green_data <= x"46";
					
				 elsif (vert <=650 and vert >=440 and horiz <=1050 and horiz>=1000) then  --TreeTrunk2-----
				
				 --#cc9f56
				    red_data   <= x"cc";
                    blue_data  <= x"9f";
                    green_data <= x"56";
					
					
				 elsif (vert <=600 and vert >=550 and horiz <=550 and horiz>=450 )   then --platform 1
				 --#CA6438
				    red_data   <= x"CA";
                    blue_data  <= x"64";
                    green_data <= x"38";
					
				elsif (vert <=600 and vert >= 500 and horiz <=800 and horiz>=650 )   then --platform 2
				 --#CA6438
				    red_data   <= x"CA";
                    blue_data  <= x"64";
                    green_data <= x"38";
					
				elsif (vert <=600 and vert >= 450 and horiz <=1000 and horiz>=950 )   then --platform 3
				 --#CA6438
				    red_data   <= x"CA";
                    blue_data  <= x"64";
                    green_data <= x"38";
					
				 end if;	
				 
				 ---------------------traps----------------------------------------------------------
				 if (vert <=650+2*wind and vert >=600+2*wind and horiz <=375 and horiz>=350-wind) then --TreeL1.1------
				
				   if wind >= 0 then
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					  
					elsif wind <= 0 then
					--#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  
					  end if;
					  
				 elsif (vert <=650-2*wind and vert >=600-2*wind and horiz <=400 and horiz>=375) then --TreeL1.1------
				 --#2a6646
				   if wind >= 0 then
				   
				      --#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  
					elsif wind <= 0 then
					
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					 end if;
					
				 elsif (vert <=650+2*wind and vert >=600+2*wind and horiz <=425 and horiz>=400) then --TreeL1.1------
				
				   if wind >= 0 then
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					  
					elsif wind <= 0 then
					--#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  end if;
				 elsif (vert <=650-2*wind and vert >=600-2*wind and horiz <=450 and horiz>=425) then --TreeL1.1------
				 --#2a6646
				   if wind >= 0 then
				   
				      --#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  
					elsif wind <= 0 then
					
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					end if;
				end if;
				 if (vert <=650+2*wind and vert >=600+2*wind and horiz <=825 and horiz>=800-wind) then --TreeL1.1------
				
				   if wind >= 0 then
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					  
					elsif wind <= 0 then
					--#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  
					  end if;
					  
				 elsif (vert <=650-2*wind and vert >=600-2*wind and horiz <=850 and horiz>=825) then --TreeL1.1------
				 --#2a6646
				   if wind >= 0 then
				   
				      --#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  
					elsif wind <= 0 then
					
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					 end if;
					
				 elsif (vert <=650+2*wind and vert >=600+2*wind and horiz <=875 and horiz>=850) then --TreeL1.1------
				
				   if wind >= 0 then
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					  
					elsif wind <= 0 then
					--#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  end if;
					  
				 elsif (vert <=650-2*wind and vert >=600-2*wind and horiz <=900 and horiz>=875) then --TreeL1.1------
				 --#2a6646
				   if wind >= 0 then
				   
				      --#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  
					elsif wind <= 0 then
					
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					 end if;
					
				 elsif (vert <=650+2*wind and vert >=600+2*wind and horiz <=925 and horiz>=900) then --TreeL1.1------
				
				   if wind >= 0 then
				    -- #9d0d04
				      red_data   <= x"9d";
                      blue_data  <= x"0d";
                      green_data <= x"04";
					  
					elsif wind <= 0 then
					--#cd1803
				      red_data   <= x"cd";
                      blue_data  <= x"18";
                      green_data <= x"03";
					  end if;
					 
					 
				end if;
				 --------------------------------------------------------------------------------

	 ------------------------------------------------------------can copy paste 
--                 if j<=550 and j >=400 and (jump >= 50 or jj >= 50 ) then 
                  if ( jj >= 50  ) then --active zone for platform

					   if (vert <=600-jump-50 and vert >=580-jump-50 and horiz <=50 + j and horiz>=0 + j)   then --player body
				 --#c13b49
				         red_data   <= x"c1";
                         blue_data  <= x"3b";
                         green_data <= x"49";
						 
						 elsif (horiz-25-j)**2+(vert-560+jump-wind+jj)**2 <= 200   then --player head
                    --F2DB67
                          red_data   <= x"F2";
                          blue_data  <= x"DB";
                          green_data <= x"67";

						  end if;
						  
				 elsif ( jj1 >= 90) then  
						  
				      if (vert <=600-jump-jj1 and vert >=580-jump-jj1 and horiz <=50 + j and horiz>=0 + j)   then --player body
				 --#c13b49
				         red_data   <= x"c1";
                         blue_data  <= x"3b";
                         green_data <= x"49";
						 
						 elsif (horiz-25-j)**2+(vert-560+jump-wind+jj1)**2 <= 200   then --player head
                    --F2DB67
                          red_data   <= x"F2";
                          blue_data  <= x"DB";
                          green_data <= x"67";

						  end if;
						  
			      elsif ( jj2 >= 70) then  
						  
				      if (vert <=600-jump-jj2-80 and vert >=580-jump-jj2-80 and horiz <=50 + j and horiz>=0 + j)   then --player body
				 --#c13b49
				         red_data   <= x"c1";
                         blue_data  <= x"3b";
                         green_data <= x"49";
						 
						 elsif (horiz-25-j)**2+(vert-560+jump-wind+jj2+80)**2 <= 200   then --player head
                    --F2DB67
                          red_data   <= x"F2";
                          blue_data  <= x"DB";
                          green_data <= x"67";

						  end if;
						 
				
			         else 
			            
				 if (horiz-25-j)**2+(vert-560+jump-wind)**2 <= 200   then --player head
                    --F2DB67
                       red_data   <= x"F2";
                       blue_data  <= x"DB";
                       green_data <= x"67";
				 
				     elsif (vert <=600-jump and vert >=580-jump and horiz <=50 + j and horiz>=0 + j)   then --player body
				      --#c13b49
				      red_data   <= x"c1";
                      blue_data  <= x"3b";
                      green_data <= x"49";
					  
					  end if;
					
--				    
                 end if;  
				 
				 
				 
				   ------------------------------game over courtains-------------------------------------------------------------------
			  
			    if (vert <=180+ct-720 and vert >=-20+ct-720 and horiz >=0 and horiz<=1280) then --TreeL1.1------
				 --#2a6646
				 if g_o >=1 and g_o<=2 then
				    red_data <= x"ff";
        		    blue_data <= x"00";
	      		    green_data <= x"00";	
	      		  elsif g_o >= 3 then  
	      		    red_data <= x"80";
        		    blue_data <= x"c0";
	      		    green_data <= x"ff";
	      		  end if;
				elsif (vert <=360-720+ct and vert >=180-720+ct and horiz >=0 and horiz<=1280) then --TreeL1.1------
				 --#2a6646
				  if g_o >=1 and g_o<=2 then
				    red_data <= x"e4";
        		    blue_data <= x"00";
	      		    green_data <= x"00";	
	      		  elsif g_o >= 3 then 
	      		    red_data <= x"69";
        		    blue_data <= x"c4";
	      		    green_data <= x"ff";
	      		  end if;
				 	
				elsif (vert <=540-720+ct and vert >=360-720+ct and horiz >=0 and horiz<=1280) then --TreeL1.1------
				 --#2a6646
				    if g_o >=1 and g_o<=2 then
				    red_data <= x"b5";
        		    blue_data <= x"00";
	      		    green_data <= x"00";	
	      		  elsif g_o >= 3 then 
	      		    red_data <= x"37";
        		    blue_data <= x"9c";
	      		    green_data <= x"ff";
	      		  end if;	
					
				elsif (vert <=720-720+ct and vert >=540-720+ct and horiz >=0 and horiz<=1280) then --TreeL1.1------
				 --#2a6646
				   if g_o >=1 and g_o<=2 then
				    red_data <= x"8b";
        		    blue_data <= x"00";
	      		    green_data <= x"00";	
	      		  elsif g_o >= 3 then 
	      		    red_data <= x"06";
        		    blue_data <= x"83";
	      		    green_data <= x"ff";
	      		  end if;
			  
			     end if;
				 
				 
           end if;
   
		   
		
           

    
end if;
end process state_proc;


     
end Behavioral;
