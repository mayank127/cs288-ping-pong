----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:40:26 04/04/2013 
-- Design Name: 
-- Module Name:    pingpong - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity pong_block is
    Port (	clk : in  STD_LOGIC;			--75Mhz
				reset : in  STD_LOGIC;
				p_l_t : in std_logic;		-- push button to move left paddle up
				p_l_b : in std_logic;		-- push button to move left paddle down	
				p_r_t : in std_logic;		-- push button to move right paddle up
				p_r_b : in std_logic;		-- push button to move right paddle down
				start  : in std_logic;		-- push button for strt

				h_counter : in std_logic_vector(11 downto 0);   --horizontal pixel counter
				v_counter : in std_logic_vector(11 downto 0);  --vertical pixel counter
				
				red	: out std_logic_vector(7 downto 0);  --red signal for the current pixel
				green : out std_logic_vector(7 downto 0);	 --green signal for the current pixel
				blue  : out std_logic_vector(7 downto 0));  --blue signal for the current pixel
end pong_block;

architecture Behavioral of pong_block is

component scores is  --component to show scores
	PORT (
			scr : in std_logic_vector(2 downto 0);
			a1 : out std_logic_vector(9 downto 0);
			a2 : out std_logic_vector(9 downto 0);
			a3 : out std_logic_vector(9 downto 0);
			a4 : out std_logic_vector(9 downto 0);
			a5 : out std_logic_vector(9 downto 0);
			a6 : out std_logic_vector(9 downto 0);
			a7 : out std_logic_vector(9 downto 0);
			a8 : out std_logic_vector(9 downto 0);
			a9 : out std_logic_vector(9 downto 0);
			a10 : out std_logic_vector(9 downto 0));
end component scores;

constant wallUp : integer range 0 to 1 := 0;		--upper end of wall
constant wallDown : integer range 0 to 480 := 480; --lower end of th wall
constant wallLeft : integer range 0 to 1:= 0;  --left end of the wall
constant wallRight : integer range 0 to 640:= 640; --right end of the wall

constant paddleHalfWidth :integer range 0 to 5:=4;  -- half width of paddle for easier calculation from center
constant paddleHalfHeight :integer range 0 to 50:= 48; -- half height of paddle for easier calculation from center
constant paddleMove : integer range 0 to 10:= 10;  --constanct amount by which paddle moves

constant paddleLeft_x : integer range 0 to 7:= 6;  	--x coordinate of left paddle's center
signal paddleLeft_y : integer range 0 to 480:= wallDown/2;  --y coordinate of left paddle's center
constant paddleRight_x : integer range 0 to 634:= 634; --x coordinate of right paddle's center
signal paddleRight_y : integer range 0 to 480:= wallDown/2;--y coordinate of right paddle's center

constant paddleMin_y : integer range 0 to 50:= paddleHalfHeight;  --min value of y center od paddle can have, i.e. touching upper wall
constant paddleMax_y : integer range 0 to 480:= wallDown - paddleHalfHeight;  --max value of y center of paddle can have, i.e. touching lower wall


constant ball_half_size : integer range 0 to 3:= 2;  --half size of square ball for eacier calculation from center
constant ball_x_init : integer := 320;   --initial x position of ball 
constant ball_y_init : integer := 240;		--initial y position of ball
signal ball_x : integer range 0 to 640:= ball_x_init; --x coorfinate of center of the ball
signal ball_y : integer range 0 to 480:= ball_y_init;  --y coordinate of center of the ball


constant ball_x_max : integer range 0 to 640:= wallRight - ball_half_size;  --max x ball can have i.e. touching right edge of wall
constant ball_x_min : integer range 0 to 3:= ball_half_size;--min x ball can have i.e. touching left edge of wall
constant ball_y_max : integer range 0 to 480:= wallDown - ball_half_size;--max y ball can have i.e. touching lower edge of wall
constant ball_y_min : integer range 0 to 3:= ball_half_size;--min y ball can have i.e. touching lower edge of wall

signal ball_vel_x : integer range -10 to 10:= 10;  --x velocity of the ball
signal ball_vel_y : integer range -20 to 20:= 5; --y velocity  of the ball
constant ball_vel_max : integer range 0 to 20:= 20; --max vel of ball in y
constant ball_vel_min : integer range -20 to 0:= -20; --min vel of ball in y
constant ball_vel_x_init : integer range 0 to 10:= 8; --initial x velocity
constant ball_vel_y_init : integer range 0 to 5:= 5; --initial y veloity


signal Move_CLK : STD_LOGIC := '0';  --clock pulse at which motion occurs
signal Move_CLK_counter : integer range 0 to 3000000:= 0;  -- counter for move clock

type state_type is (stopped,moving);  --states of the simulation
signal current_s: state_type;  --current state variable

signal scoreLeft : std_logic_vector(2 downto 0) := "000";  --left score 
signal scoreRight : std_logic_vector(2 downto 0):= "000"; --right score

signal restrt : STD_LOGIC := '0';  --restart is 1 when ball touches back wal and game restarts with score updation
signal restrt_counter : integer range 0 to 100:= 0; --counter for autorestart


signal horizontal_counter : integer:=0;  --horizintal counter for hsync
signal vertical_counter   : integer :=0;  --vertical counterfor vsync

signal s1_1:std_logic_vector(9 downto 0);  --10 vectors to show 10 x 10 grid of scoreLeft
signal s2_1:std_logic_vector(9 downto 0);
signal s3_1:std_logic_vector(9 downto 0);
signal s4_1:std_logic_vector(9 downto 0);
signal s5_1:std_logic_vector(9 downto 0);
signal s6_1:std_logic_vector(9 downto 0);
signal s7_1:std_logic_vector(9 downto 0);
signal s8_1:std_logic_vector(9 downto 0);
signal s9_1:std_logic_vector(9 downto 0);
signal s10_1:std_logic_vector(9 downto 0);

signal s1_2:std_logic_vector(9 downto 0);		--10 vectors to show 10 x 10 grid of scoreRight
signal s2_2:std_logic_vector(9 downto 0);
signal s3_2:std_logic_vector(9 downto 0);
signal s4_2:std_logic_vector(9 downto 0);
signal s5_2:std_logic_vector(9 downto 0);
signal s6_2:std_logic_vector(9 downto 0);
signal s7_2:std_logic_vector(9 downto 0);
signal s8_2:std_logic_vector(9 downto 0);
signal s9_2:std_logic_vector(9 downto 0);
signal s10_2:std_logic_vector(9 downto 0);

signal strt1 : STD_LOGIC :='1';  --strt1  is kept alway 1 to keep the states moving
--signal reset : STD_LOGIC :='0';
--signal p_l_t : STD_LOGIC :='0';
--signal p_l_b : STD_LOGIC :='0';
--signal p_r_t : STD_LOGIC :='0';
--signal p_r_b : STD_LOGIC :='0';




begin

scr1: scores PORT MAP (scoreLeft,s1_1,s2_1,s3_1,s4_1,s5_1,s6_1,s7_1,s8_1,s9_1,s10_1);  --portmap to get score vector1
scr2: scores PORT MAP(scoreRight,s1_2,s2_2,s3_2,s4_2,s5_2,s6_2,s7_2,s8_2,s9_2,s10_2);	--posrtmap to get score vector2

States : process (strt1,reset) --process to change states
begin
		if reset = '1'  then  --if reset turns 1 than everythin stops
			current_s <= stopped;
		elsif strt1 ='1' then --strt1 is kept always to one to keep moving
			current_s <= moving;
		else
			current_s <= stopped;
		end if;
end process;
--
process (clk , current_s) -- to move things making new clock
begin
		if clk'event and clk='1' and current_s = moving then  --on every edge of clk and when state is moving run the clock 
				Move_CLK_Counter <= Move_CLK_Counter +1;
					if (Move_CLK_Counter = 1000000) then  --this is 75.0 Hz clock for movement updation 
						Move_CLK <= not Move_CLK;
						Move_CLK_Counter <=0;
					end if;
		elsif clk'event and clk='1' and current_s = stopped then  --stopped when state is stopped.
				Move_CLK <=Move_CLK;
				Move_CLK_Counter <= 0;
		end if;
end process;

paddle_left_move : process (Move_CLK,reset) -- to move left paddle
begin
	if reset = '1' or current_s = stopped then -- if reset move the paddle back to initia;
		paddleLeft_y <= wallDown/2;
	elsif Move_CLK'event and Move_CLK='1' then --otherwise move on move clk signal
		if(p_l_b= '1') then --move down till max
				if(paddleLeft_y + paddleMove < paddleMax_y) then  --not touching bottom edge of wall
				paddleLeft_y <= paddleLeft_y + paddleMove;
				else --else no change
				paddleLeft_y <= paddleMax_y;
				end if;
		elsif(p_l_t='1') then --move up till min
				if(paddleLeft_y - paddleMove > paddleMin_y) then  --not touching the upper edge
				paddleLeft_y <= paddleLeft_y - paddleMove;
				else  --els no change
				paddleLeft_y <= paddleMin_y;
				end if;
		else --else no change
			paddleLeft_y <= paddleLeft_y;
		end if;
	end if;
end process;

paddle_right_move : process (Move_CLK,reset) --to move right paddle
begin
	if reset= '1' or current_s = stopped then --reset to initial
		paddleRight_y <= wallDown/2;
	elsif Move_CLK'event and Move_CLK='1' then --otherwise move on move clk signal
		if(p_r_b='1') then --move down till max
			if(paddleright_y + paddleMove < paddleMax_y) then  --not touching lower wall
				paddleright_y <= paddleright_y + paddleMove;  
			else  --else  no change
				paddleright_y <= paddleMax_y;
			end if;
		elsif(p_r_t='1') then --mobe up till min
			if(paddleright_y - paddleMove > paddleMin_y) then --not touching upper wall
				paddleright_y <= paddleright_y - paddleMove;
			else  --else no change
				paddleright_y <= paddleMin_y;
			end if;
		else  --else no change
			paddleright_y <= paddleright_y;
		end if;
	end if;
end process;

ball_Move : process (Move_CLK,ball_vel_y,ball_vel_x,ball_x,ball_y,reset) --ball movement
begin
if reset='1' or current_s = stopped then  --reset ball to initial location and scores to 0
		ball_x <= wallRight/2;
		ball_y <= wallDown/2;
		ball_vel_x <= ball_vel_x_init;
		ball_vel_y <= ball_vel_y_init;
		scoreLeft <= "000";
		scoreRight <= "000";
	
elsif Move_CLK'event and Move_CLK='1' then  --else clcok dependent motion
	if(restrt = '1') then		--if restrt 1 than wait for 20 cloack cycles and than restart the game by resettinh ball
		if(restrt_counter=20)  then
			restrt<='0';
			ball_x <= ball_x_init;
			ball_y <= ball_y_init;
			ball_vel_x <= ball_vel_x_init;
			ball_vel_y <= ball_vel_y_init;
			restrt_counter<=0;
		else
			restrt_counter <= restrt_counter + 1;
		end if;
			
	  --move case otherwise
		else
			if (ball_y + ball_vel_y >= ball_y_max)OR (ball_y + ball_vel_y <= ball_y_min) then  --ball hits up or down wall
				if(ball_vel_y = 0) then
					ball_vel_y <= 5;
				elsif(ball_y<=ball_y_max AND ball_y>ball_y_min) then   --only when inside the board chage velocity
					ball_vel_y <= -ball_vel_y; --reverse y direction
				end if;
				ball_x <= ball_x + ball_vel_x; --will change position every iteration 
				ball_y <= ball_y + ball_vel_y;--Already vel have been changed will result in jump approximately correct
			
			elsif ((ball_x + ball_vel_x <= paddleLeft_x + paddleHalfWidth + ball_half_size) AND 
			(ball_y + ball_vel_y <= paddleLeft_y + paddleHalfHeight + ball_half_size) AND
			(ball_y + ball_vel_y >= paddleLeft_y - paddleHalfHeight - ball_half_size)) then --ball hits left paddle
				
				ball_vel_x <= -ball_vel_x; --reverse x velocity
				
				if ball_vel_y > 0 then  --change y veloctiy on the basis of where it hit the paddle
					ball_vel_y <= ball_vel_y + (ball_vel_y * (ball_y - paddleLeft_y))/( paddleHalfHeight);
				elsif ball_vel_y=0 then
					ball_vel_y <= 5;
				else
					ball_vel_y <= ball_vel_y - (ball_vel_y * (ball_y - paddleLeft_y))/( paddleHalfHeight);
				end if;
				
				if(ball_vel_y>ball_vel_max) then --if y vel greater than max than reset
					ball_vel_y <= ball_vel_max;
				elsif (ball_vel_y<ball_vel_min) then --if y vel lesser than min than reset
					ball_vel_y <= ball_vel_min;
				end if;	
				
				ball_x <= ball_x + ball_vel_x; --will change position every iteration 
				ball_y <= ball_y + ball_vel_y;--Already vel have been changed will result in jump approximately correct
			
			elsif ((ball_x +ball_vel_x >= paddleRight_x - paddleHalfWidth - ball_half_size) AND 
			(ball_y + ball_vel_y <= paddleRight_y + paddleHalfHeight + ball_half_size) AND
			(ball_y + ball_vel_y >= paddleRight_y - paddleHalfHeight - ball_half_size)) then --if ball hits right paddle
				
				ball_vel_x <= -ball_vel_x; --reverse x velocity
				
				if ball_vel_y >= 0 then  --change y velocity on the basis of where it hit the paddle
					ball_vel_y <= ball_vel_y + (ball_vel_y * (ball_y - paddleRight_y))/(paddleHalfHeight);
				elsif(ball_vel_y = 0) then
					ball_vel_y <= 5;
				else
					ball_vel_y <= ball_vel_y - (ball_vel_y * (ball_y - paddleRight_y))/(paddleHalfHeight);
				end if;
				
				if(ball_vel_y>ball_vel_max) then  --if y vel greater than max than reset
					ball_vel_y <= ball_vel_max;
				elsif (ball_vel_y<ball_vel_min) then --if y vel lesser than min than reset
					ball_vel_y <= ball_vel_min;
				end if;
				
				ball_x <= ball_x + ball_vel_x; --will change position every iteration 
				ball_y <= ball_y + ball_vel_y;--Already vel have been changed will result in jump approximately correct
			
			elsif (ball_x + ball_vel_x < 0) then--Not sufficient --If ball misses paddle left and goes behind towards the wall
				scoreRight <= scoreRight + 1;  --increment socre and restrt
				restrt <= '1';
				
			elsif (ball_x + ball_vel_x > wallRight) then --if ball misses paddle right
				scoreLeft <= scoreLeft + 1;  --increment score and  restart
				restrt<= '1';
			else   --else no change in velocity
				ball_vel_x <= ball_vel_x;
				ball_vel_y <= ball_vel_y;
				ball_x <= ball_x + ball_vel_x; --will change position every iteration 
				ball_y <= ball_y + ball_vel_y;--Already vel have been changed will result in jump approximately correct
		end if;
		
	end if;
end if;
end process;


draw : process(clk)  --draw process of the game
begin
horizontal_counter <= conv_integer(h_counter);
vertical_counter <= conv_integer(v_counter);
if clk'event and clk = '1' then  --on 75 MHz clock
	if (horizontal_counter >= 144 ) -- 144
      and (horizontal_counter < 784 ) -- 784
      and (vertical_counter >= 39) -- 39
      and (vertical_counter < 519 ) -- 519
		then
 
       --here you paint!!
		 
		if(horizontal_counter>=444 AND horizontal_counter<=453 )AND  --to paint score's 10x10 matrix each pixel accordingly
		(vertical_counter>=44 AND vertical_counter<=53 ) then
				case vertical_counter is
					when 44 =>
						red <= (others => '0');
						green <= (others => s1_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 45=>
						red <= (others => '0');
						green <= (others => s2_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 46 =>
						red <= (others => '0');
						green <= (others => s3_1(453 - horizontal_counter));
						blue <= (others => '0');
					when	47 =>
						red <= (others => '0');
						green <= (others => s4_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 48 => 
						red <= (others => '0');
						green <= (others => s5_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 49 =>
						red <= (others => '0');
						green <= (others => s6_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 50 => 
						red <= (others => '0');
						green <= (others => s7_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 51 =>
						red <= (others => '0');
						green <= (others => s8_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 52 => 
						red <= (others => '0');
						green <= (others => s9_1(453 - horizontal_counter));
						blue <= (others => '0');
					when 53 =>
						red <= (others => '0');
						green <= (others => s10_1(453 - horizontal_counter));
						blue <= (others => '0');
					when others =>
						red <= (others => '0');
						green <= (others => '0');
						blue <= (others => '0');
					end case;
				
			elsif(horizontal_counter>=474 AND horizontal_counter<=483 ) AND  --to print score 2's 10x10 matrix
				(vertical_counter>=44 AND vertical_counter<=53 ) then
				case vertical_counter is
					when 44 =>
						red <= (others => '0');
						green <= (others => s1_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 45=>
						red <= (others => '0');
						green <= (others => s2_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 46 =>
						red <= (others => '0');
						green <= (others => s3_2(483 - horizontal_counter));
						blue <= (others => '0');
					when	47 =>
						red <= (others => '0');
						green <= (others => s4_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 48 => 
						red <= (others => '0');
						green <= (others => s5_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 49 =>
						red <= (others => '0');
						green <= (others => s6_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 50 => 
						red <= (others => '0');
						green <= (others => s7_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 51 =>
						red <= (others => '0');
						green <= (others => s8_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 52 => 
						red <= (others => '0');
						green <= (others => s9_2(483 - horizontal_counter));
						blue <= (others => '0');
					when 53 =>
						red <= (others => '0');
						green <= (others => s10_2(483 - horizontal_counter));
						blue <= (others => '0');
					when others =>
						red <= (others => '0');
						green <= (others => '0');
						blue <= (others => '0');
					end case;
			elsif(horizontal_counter>=144 + ball_x - ball_half_size  --when counter in region of ball, draw red ball
			AND horizontal_counter<=144 + ball_x + ball_half_size
			AND vertical_counter >= 39 + ball_y - ball_half_size
			AND vertical_counter <= 39 + ball_y + ball_half_size) then
				red <= (others => '1');
				green <= (others => '0');
				blue <= (others => '0');
		 
		 elsif (horizontal_counter >= 144 + paddleLeft_x - paddleHalfWidth --Left Paddle Draw blue
				AND horizontal_counter <= 144 + paddleLeft_x + paddleHalfWidth
				AND vertical_counter >= 39 + paddleLeft_y - paddleHalfHeight
				AND vertical_counter <= 39 + paddleLeft_y + paddleHalfHeight) then
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '1');
		elsif (horizontal_counter >= 144 + paddleright_x - paddleHalfWidth --right Paddle Draw blue
				AND horizontal_counter <= 144 + paddleright_x + paddleHalfWidth
				AND vertical_counter >= 39 + paddleright_y - paddleHalfHeight
				AND vertical_counter <= 39 + paddleright_y + paddleHalfHeight) then
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '1');
		
		else --background is white
			red <= (others => '1');
			green <= (others => '1');
			blue <= (others => '1');
		end if;
		 
      else		--everywhere else is black
        red <= (others=>'0');
        green <= (others=>'0');
        blue <= (others=>'0');
   end if;
end if;

end process;

end Behavioral;

