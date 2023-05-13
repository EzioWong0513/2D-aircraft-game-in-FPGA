----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2023 15:13:08
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
    Port (clk: in std_logic;
    hsync, vsync: out std_logic;
    red, green, blue: out std_logic_vector(3 downto 0);
    moveU, moveD, moveL, moveR: in std_logic;
    shoot: in std_logic;
    display_enemy: in std_logic;
    reset_game: in std_logic);
end main;

architecture Behavioral of main is
signal Stage: std_logic_vector(2 downto 0) := "100"; -- Starts from stage1 (stage2="010", stage3="001")
--orginal
constant H_TOTAL: integer := 1344-1;
constant H_SYNC: integer := 48-1;
constant H_BACK: integer := 240-1;
constant H_START: integer := 48+240-1;
constant H_ACTIVE: integer := 1024-1;
constant H_END: integer := 1344-32-1-50;
constant H_FRONT: integer := 32-1;
constant V_TOTAL: integer := 625-1;
constant V_SYNC: integer := 3-1;
constant V_BACK: integer := 12-1;
constant V_START: integer := 3+12;
constant V_ACTIVE: integer := 600-1;
constant V_END: integer := 625-10-1;
constant V_FRONT: integer := 10-1;
signal hcount, vcount: integer;
signal flag: integer;
--bullet
constant BULLET_WIDTH: integer := 50;
constant BULLET_HEIGHT: integer := 50;
signal bullet_x: integer := -BULLET_WIDTH; -- Initialize off-screen
signal bullet_y: integer := -BULLET_HEIGHT; -- Initialize off-screen
signal shoot_bullet: std_logic := '0';
signal new_bullet_x: integer;
signal new_bullet_y: integer;
--Stage1enemy
constant ENEMY_WIDTH: integer := 100;
constant ENEMY_HEIGHT: integer := 100;
signal enemy_x: integer := H_END - ENEMY_HEIGHT;
signal enemy_y: integer := V_TOTAL/2;
signal enemy_dx: integer := 20;
signal enemy_dy: integer := 20;
signal enemy_display: std_logic := '0';

--Stage2enemyA
signal s2aenemy_x: integer := H_END - ENEMY_HEIGHT;
signal s2aenemy_y: integer := 200;
signal s2aenemy_display: std_logic := '0';
--Stage2eneymB
signal s2benemy_x: integer := H_END - ENEMY_HEIGHT;
signal s2benemy_y: integer := 400;
signal s2benemy_display: std_logic := '0';
--Stage2eneymC
signal s2cenemy_x: integer := H_END - ENEMY_HEIGHT;
signal s2cenemy_y: integer := 600;
signal s2cenemy_display: std_logic := '0';
--kill_enemy
signal enemy_alive: std_logic := '1';
signal s2aenemy_alive: std_logic := '0';
signal s2benemy_alive: std_logic := '0';
signal s2cenemy_alive: std_logic := '0';
--enemy_bullet
constant ENEMY_BULLET_WIDTH: integer := 20;
constant ENEMY_BULLET_HEIGHT: integer := 20;
signal enemy_bullet_x: integer := -ENEMY_BULLET_WIDTH; -- Initialize off-screen
signal enemy_bullet_y: integer := -ENEMY_BULLET_HEIGHT; -- Initialize off-screen
signal enemy_shoot_bullet: std_logic := '0';
signal new_enemy_bullet_x: integer;
signal new_enemy_bullet_y: integer;
--s2enemyA_bullet
signal s2aenemy_bullet_x: integer := -ENEMY_BULLET_WIDTH; -- Initialize off-screen
signal s2aenemy_bullet_y: integer := -ENEMY_BULLET_HEIGHT; -- Initialize off-screen
signal s2aenemy_shoot_bullet: std_logic := '0';
signal s2anew_enemy_bullet_x: integer;
signal s2anew_enemy_bullet_y: integer;
--s2enmeyB_buleet
signal s2benemy_bullet_x: integer := -ENEMY_BULLET_WIDTH; -- Initialize off-screen
signal s2benemy_bullet_y: integer := -ENEMY_BULLET_HEIGHT; -- Initialize off-screen
signal s2benemy_shoot_bullet: std_logic := '0';
signal s2bnew_enemy_bullet_x: integer;
signal s2bnew_enemy_bullet_y: integer;
--s2enmeyC_buleet
signal s2cenemy_bullet_x: integer := -ENEMY_BULLET_WIDTH; -- Initialize off-screen
signal s2cenemy_bullet_y: integer := -ENEMY_BULLET_HEIGHT; -- Initialize off-screen
signal s2cenemy_shoot_bullet: std_logic := '0';
signal s2cnew_enemy_bullet_x: integer;
signal s2cnew_enemy_bullet_y: integer;
--kill_aircraft
signal aircraft_alive: std_logic := '1';

component clock_divider is
 generic (N: integer);
   Port (
       clk : IN STD_LOGIC;
       clk_out : OUT STD_LOGIC
   );
end component;
signal clk1Hz, clk10Hz, clk50MHz: std_logic;

constant X_STEP : integer := 40;
constant Y_STEP : integer := 40;
constant SIZE : integer := 120;
signal x : integer := H_START;
signal y : integer := V_START;
signal dx : integer := X_STEP;
signal dy : integer := Y_STEP; 
signal flagx: std_logic := '1';
signal flagy: std_logic := '1';
signal s2aflagx: std_logic := '1';
signal s2aflagy: std_logic := '1';
signal s2bflagx: std_logic := '1';
signal s2bflagy: std_logic := '1';
signal s2cflagx: std_logic := '1';
signal s2cflagy: std_logic := '1';
type colors is (C_Black, C_Green, C_Blue, C_Red, C_White, C_Yellow);
type T_1D is array(0 to 4) of colors;
signal rand_val: std_logic_vector(2 downto 0);
signal color : colors;
begin
u_clk50mhz: clock_divider generic map(N=>1) port map(clk, clk50MHz); 

pixel_count_proc: process(clk50MHz)
begin
    if (rising_edge(clk50MHz)) then
        if(hcount = H_TOTAL) then
            hcount <= 0;
        else
            hcount <= hcount + 1;
        end if;
    end if;
end process pixel_count_proc;

hsync_gen_proc: process(hcount) begin
    if(hcount <= H_SYNC) then
        hsync <= '1';
    else
        hsync <= '0';
    end if;
end process hsync_gen_proc;

line_count_proc: process (clk50MHz)
begin
    if (rising_edge(clk50MHz)) then
        if (hcount = H_TOTAL) then 
            if (vcount = V_TOTAL) then
                vcount <= 0;
            else
                vcount <= vcount + 1;
            end if;
        end if;
    end if;
end process line_count_proc;

vsync_gen_proc : process (hcount)
begin
    if (vcount <= V_SYNC) then
        vsync <= '1';
    else
        vsync <= '0';
    end if;
end process vsync_gen_proc;

u_clk1hz : clock_divider generic map(N =>50000000) port map(clk, clk1Hz);
u_clk10hz : clock_divider generic map(N =>5000000) port map(clk, clk10Hz);

process(clk10Hz)
begin
    if(rising_edge(clk10Hz)) then
        rand_val <= rand_val(1 downto 0) & (rand_val(2) xor rand_val(1));
        -- Reset game state when reset_game is '1'
        if (reset_game = '1') then
            x <= H_START;
            y <= V_START;
            enemy_x <= H_END - ENEMY_HEIGHT;
            enemy_y <= V_TOTAL / 2;
            enemy_alive <= '1';
            s2aenemy_alive<= '0';
            s2benemy_alive<= '0';
            s2cenemy_alive<= '0';
            aircraft_alive <= '1';
            shoot_bullet <= '0';
            bullet_x <= -BULLET_WIDTH;
            bullet_y <= -BULLET_HEIGHT;
            enemy_shoot_bullet <= '0';
            s2aenemy_shoot_bullet <= '0';
            s2benemy_shoot_bullet <= '0';
            s2cenemy_shoot_bullet <= '0';
            enemy_bullet_x <= -ENEMY_BULLET_WIDTH;
            s2aenemy_bullet_x <= -ENEMY_BULLET_WIDTH;
            s2benemy_bullet_x <= -ENEMY_BULLET_WIDTH;
            s2cenemy_bullet_x <= -ENEMY_BULLET_WIDTH;
            enemy_bullet_y <= -ENEMY_BULLET_HEIGHT;
            s2aenemy_bullet_y <= -ENEMY_BULLET_HEIGHT;
            s2benemy_bullet_y <= -ENEMY_BULLET_HEIGHT;
            s2cenemy_bullet_y <= -ENEMY_BULLET_HEIGHT;
            Stage <= "100";
        else
            -- The existing code for movements, shooting, and enemy actions
            --/*move up, down, left, right && shoot
            if (moveU = '1') then
                if (x < (H_END - SIZE)) then
                    x <= x + dx; 
                end if;
            end if;
           
            if (moveD = '1') then
                if (x > H_START) then
                    x <= x - dx; 
                end if;
            end if;
           
            if (moveL = '1') then
                if (y > V_START) then
                    y <= y - dy;
                end if;
            end if;
           
            if (moveR = '1') then
                if (y < (V_END - SIZE)) then
                    y <= y + dy;
                end if;
            end if;   
                   
            --shoot
            if (shoot = '1' and bullet_y <= V_START) then
                 new_bullet_x <= x + (SIZE / 2) - (BULLET_WIDTH / 2);
                new_bullet_y <= y - BULLET_HEIGHT;
            end if;
                   
            --enemy
            if(Stage = "100") then
                if(display_enemy = '1') then
                    if (enemy_x + ENEMY_HEIGHT >= H_END) then
                        flagx <= '0';       
                    elsif (enemy_x <= H_START) then
                        flagx <= '1';
                    end if;
                                        
                    if (enemy_y + ENEMY_WIDTH >= V_END) then
                        flagy <= '0';
                    elsif (enemy_y <= V_START) then
                        flagy <= '1';
                    end if;
                              
                    if(flagx = '1') then
                        enemy_x <= enemy_x + enemy_dx;
                    else
                        enemy_x <= enemy_x - enemy_dx;
                    end if;
                                        
                    if(flagy = '1') then
                        enemy_y <= enemy_y + enemy_dy;
                    else
                        enemy_y <= enemy_y - enemy_dy;
                    end if;
                end if;
            elsif(Stage = "010") then
               if(display_enemy = '1') then
                    if ((s2aenemy_x + ENEMY_HEIGHT >= H_END)) then
                        s2aflagx <= '0';      
                        if (rand_val(0) = '1') then
                            s2aflagy <= '0';
                        else
                            s2aflagy <= '1';
                        end if;
                    elsif ((s2aenemy_x <= H_START)) then
                        s2aflagx <= '1';
                        if (rand_val(0) = '1') then
                            s2aflagy <= '1';
                        else
                            s2aflagy <= '0';
                        end if;
                    end if;
                    
                    if ((s2benemy_x + ENEMY_HEIGHT >= H_END)) then
                        s2bflagx <= '0';
                        if (rand_val(1) = '1') then
                            s2bflagy <= '0';
                        else
                            s2bflagy <= '0';
                        end if;  
                    elsif ((s2benemy_x <= H_START)) then
                        s2bflagx <= '1';
                        if (rand_val(1) = '1') then
                            s2bflagy <= '1';
                        else
                            s2bflagy <= '0';
                        end if;  
                    end if;
                    
                    if ((s2cenemy_x + ENEMY_HEIGHT >= H_END) ) then
                        s2cflagx <= '0';
                        if (rand_val(2) = '1') then
                            s2cflagy <= '1';
                        else
                            s2cflagy <= '0';
                        end if;        
                    elsif ((s2cenemy_x <= H_START)) then
                        s2cflagx <= '1';
                        if (rand_val(2) = '1') then
                            s2cflagy <= '1';
                        else
                            s2cflagy <= '0';
                        end if;  
                    end if;
                                       
                    if (s2aenemy_y + ENEMY_WIDTH >= V_END) then
                        s2aflagy <= '0';
                    elsif (s2aenemy_y <= V_START) then
                        s2aflagy <= '1';
                    end if;
                    
                    if (s2benemy_y + ENEMY_WIDTH >= V_END) then
                        s2bflagy <= '0';
                    elsif (s2benemy_y <= V_START) then
                        s2bflagy <= '1';
                    end if;
                    
                    if (s2cenemy_y + ENEMY_WIDTH >= V_END) then
                        s2cflagy <= '0';
                    elsif (s2cenemy_y <= V_START) then
                        s2cflagy <= '1';
                    end if;
                    
                      
                    if(s2aflagx = '1') then
                        s2aenemy_x <= s2aenemy_x + 15;
                    else
                        s2aenemy_x <= s2aenemy_x - 15;
                    end if;
                    
                    if(s2bflagx = '1') then
                        s2benemy_x <= s2benemy_x + 25;
                    else
                        s2benemy_x <= s2benemy_x - 25;
                    end if;
                    
                    if(s2cflagx = '1') then
                        s2cenemy_x <= s2cenemy_x + 10;
                    else
                        s2cenemy_x <= s2cenemy_x - 10;
                    end if;
                                        
                    if(s2aflagy = '1') then
                        s2aenemy_y <= s2aenemy_y + enemy_dy;
                    else
                        s2aenemy_y <= s2aenemy_y - enemy_dy;
                    end if;
                    
                    if(s2bflagy = '1') then
                        s2benemy_y <= s2benemy_y + enemy_dy;
                    else
                        s2benemy_y <= s2benemy_y - enemy_dy;
                    end if;
                    
                    if(s2cflagy = '1') then
                        s2cenemy_y <= s2cenemy_y + enemy_dy;
                    else
                        s2cenemy_y <= s2cenemy_y - enemy_dy;
                    end if;
                end if;
            else
                
            end if;
            
            --move up, down, left, right && shoot END*/
            
            if(Stage = "100") then
                --/*bullet_movement_process
               if(enemy_alive = '1' and enemy_bullet_y <= V_START) then
                   new_enemy_bullet_x <= enemy_x + (ENEMY_WIDTH / 2) - (ENEMY_BULLET_WIDTH / 2);
                   new_enemy_bullet_y <= enemy_y - ENEMY_BULLET_HEIGHT;
               end if;
               
                if (shoot_bullet = '1') then
                    if (bullet_x < H_END) then
                        bullet_x <= bullet_x + dx;
                    else
                        shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                    end if;
                elsif (shoot = '1' and shoot_bullet = '0') then
                    shoot_bullet <= '1';
                    bullet_x <= x + SIZE;
                    bullet_y <= y + (SIZE / 2) - (BULLET_WIDTH / 2); -- Set the bullet_y initial position to the top of the aircraft
                else
                    shoot_bullet <= '0';
                    bullet_x <= -BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                end if;
                -- Check for collision with enemy
                if (bullet_x >= enemy_x and bullet_x < enemy_x + ENEMY_WIDTH and bullet_y >= enemy_y and bullet_y < enemy_y + ENEMY_HEIGHT and enemy_alive = '1') then
                    enemy_alive <= '0'; -- Enemy is killed
                    shoot_bullet <= '0'; -- Bullet disappears
                    bullet_x <= -BULLET_WIDTH; -- Set the bullet's position off-screen
                    s2aenemy_alive <= '1'; -- Enemy is killed
                    s2benemy_alive <= '1'; -- Enemy is killed
                    s2cenemy_alive <= '1'; -- Enemy is killed
                    Stage <= "010";
                end if;
                --bullet_movement_process END*/
    
        --enemy_bullet_movement_process          
                if (enemy_shoot_bullet = '1') then
                    if (enemy_bullet_x > 0) then
                        enemy_bullet_x <= enemy_bullet_x - dx;
                    else
                        enemy_shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                    end if;
                -- Add the following lines to trigger shooting when the enemy is alive
                elsif (enemy_alive = '1' and enemy_shoot_bullet = '0') then
                    enemy_shoot_bullet <= '1';
                    enemy_bullet_x <= enemy_x - ENEMY_BULLET_WIDTH;
                    enemy_bullet_y <= enemy_y + (ENEMY_HEIGHT / 2) - (ENEMY_BULLET_HEIGHT / 2); -- Set the bullet_y initial position to the top of the enemy
                -- End of added lines
                else
                    enemy_shoot_bullet <= '0';
                    enemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                end if;
                -- Check for collision with aircraft
                if (enemy_bullet_x >= x and enemy_bullet_x < x + SIZE and enemy_bullet_y >= y and enemy_bullet_y < y + SIZE and aircraft_alive = '1') then
                    aircraft_alive <= '0'; -- Aircraft is hit
                    enemy_shoot_bullet <= '0'; -- Enemy bullet disappears
                    enemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Set the enemy bullet's position off-screen
                end if;
        --enemy_bullet_movement_process END*/
              elsif (Stage="010") then
                             enemy_shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                             enemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Set the enemy bullet's position off-screen
                             if(s2aenemy_alive = '1' and s2aenemy_bullet_y <= V_START) then
                                 s2anew_enemy_bullet_x <= s2aenemy_x + (ENEMY_WIDTH / 2) - (ENEMY_BULLET_WIDTH / 2);
                                 s2anew_enemy_bullet_y <= s2aenemy_y - ENEMY_BULLET_HEIGHT;
                             end if;
                             if(s2benemy_alive = '1' and s2benemy_bullet_y <= V_START) then
                                 s2bnew_enemy_bullet_x <= s2benemy_x + (ENEMY_WIDTH / 2) - (ENEMY_BULLET_WIDTH / 2);
                                 s2bnew_enemy_bullet_y <= s2benemy_y - ENEMY_BULLET_HEIGHT;
                             end if;
                             if(s2cenemy_alive = '1' and s2cenemy_bullet_y <= V_START) then
                                 s2cnew_enemy_bullet_x <= s2cenemy_x + (ENEMY_WIDTH / 2) - (ENEMY_BULLET_WIDTH / 2);
                                 s2cnew_enemy_bullet_y <= s2cenemy_y - ENEMY_BULLET_HEIGHT;
                             end if;
                              
                              if (shoot_bullet = '1') then
                                  if (bullet_x < H_END) then
                                      bullet_x <= bullet_x + dx;
                                  else
                                      shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                                  end if;
                              elsif (shoot = '1' and shoot_bullet = '0') then
                                  shoot_bullet <= '1';
                                  bullet_x <= x + SIZE;
                                  bullet_y <= y + (SIZE / 2) - (BULLET_WIDTH / 2); -- Set the bullet_y initial position to the top of the aircraft
                              else
                                  shoot_bullet <= '0';
                                  bullet_x <= -BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                              end if;
                              -- Check for collision with s2a enemy
                              if (bullet_x >= s2aenemy_x and bullet_x < s2aenemy_x + ENEMY_WIDTH and bullet_y >= s2aenemy_y and bullet_y < s2aenemy_y + ENEMY_HEIGHT and s2aenemy_alive = '1') then
                                  s2aenemy_alive <= '0'; -- Enemy is killed
                                  shoot_bullet <= '0'; -- Bullet disappears
                                  bullet_x <= -BULLET_WIDTH; -- Set the bullet's position off-screen
                              end if;
                              -- Check for collision with s2b enemy
                              if (bullet_x >= s2benemy_x and bullet_x < s2benemy_x + ENEMY_WIDTH and bullet_y >= s2benemy_y and bullet_y < s2benemy_y + ENEMY_HEIGHT and s2benemy_alive = '1') then
                                  s2benemy_alive <= '0'; -- Enemy is killed
                                  shoot_bullet <= '0'; -- Bullet disappears
                                  bullet_x <= -BULLET_WIDTH; -- Set the bullet's position off-screen
                              end if;
                              -- Check for collision with s2b enemy
                              if (bullet_x >= s2cenemy_x and bullet_x < s2cenemy_x + ENEMY_WIDTH and bullet_y >= s2cenemy_y and bullet_y < s2cenemy_y + ENEMY_HEIGHT and s2cenemy_alive = '1') then
                                    s2cenemy_alive <= '0'; -- Enemy is killed
                                    shoot_bullet <= '0'; -- Bullet disappears
                                    bullet_x <= -BULLET_WIDTH; -- Set the bullet's position off-screen
                              end if;
                              --bullet_movement_process END*/
                  
                      --s2a enemy_bullet_movement_process          
                              if (s2aenemy_shoot_bullet = '1') then
                                  if (s2aenemy_bullet_x > 0) then
                                      s2aenemy_bullet_x <= s2aenemy_bullet_x - dx;
                                  else
                                      s2aenemy_shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                                  end if;
                              -- Add the following lines to trigger shooting when the enemy is alive
                              elsif (s2aenemy_alive = '1' and s2aenemy_shoot_bullet = '0') then
                                  s2aenemy_shoot_bullet <= '1';
                                  s2aenemy_bullet_x <= s2aenemy_x - ENEMY_BULLET_WIDTH;
                                  s2aenemy_bullet_y <= s2aenemy_y + (ENEMY_HEIGHT / 2) - (ENEMY_BULLET_HEIGHT / 2); -- Set the bullet_y initial position to the top of the enemy
                              -- End of added lines
                              else
                                  s2aenemy_shoot_bullet <= '0';
                                  s2aenemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                              end if;
                              -- Check for collision with aircraft
                              if (s2aenemy_bullet_x >= x and s2aenemy_bullet_x < x + SIZE and s2aenemy_bullet_y >= y and s2aenemy_bullet_y < y + SIZE and aircraft_alive = '1') then
                                  aircraft_alive <= '0'; -- Aircraft is hit
                                  s2aenemy_shoot_bullet <= '0'; -- Enemy bullet disappears
                                  s2aenemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Set the enemy bullet's position off-screen
                              end if;
                      --s2a enemy_bullet_movement_process END*/
                      
                      --s2b enemy_bullet_movement_process          
                              if (s2benemy_shoot_bullet = '1') then
                                  if (s2benemy_bullet_x > 0) then
                                      s2benemy_bullet_x <= s2benemy_bullet_x - dx;
                                  else
                                      s2benemy_shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                                  end if;
                              -- Add the following lines to trigger shooting when the enemy is alive
                              elsif (s2benemy_alive = '1' and s2benemy_shoot_bullet = '0') then
                                  s2benemy_shoot_bullet <= '1';
                                  s2benemy_bullet_x <= s2benemy_x - ENEMY_BULLET_WIDTH;
                                  s2benemy_bullet_y <= s2benemy_y + (ENEMY_HEIGHT / 2) - (ENEMY_BULLET_HEIGHT / 2); -- Set the bullet_y initial position to the top of the enemy
                              -- End of added lines
                              else
                                  s2benemy_shoot_bullet <= '0';
                                  s2benemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                              end if;
                              -- Check for collision with aircraft
                              if (s2benemy_bullet_x >= x and s2benemy_bullet_x < x + SIZE and s2benemy_bullet_y >= y and s2benemy_bullet_y < y + SIZE and aircraft_alive = '1') then
                                  aircraft_alive <= '0'; -- Aircraft is hit
                                  s2benemy_shoot_bullet <= '0'; -- Enemy bullet disappears
                                  s2benemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Set the enemy bullet's position off-screen
                              end if;
                      --s2b enemy_bullet_movement_process END*/
                      --s2c enemy_bullet_movement_process          
                            if (s2cenemy_shoot_bullet = '1') then
                                if (s2cenemy_bullet_x > 0) then
                                    s2cenemy_bullet_x <= s2cenemy_bullet_x - dx;
                                else
                                    s2cenemy_shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                                end if;
                            -- Add the following lines to trigger shooting when the enemy is alive
                            elsif (s2cenemy_alive = '1' and s2cenemy_shoot_bullet = '0') then
                                s2cenemy_shoot_bullet <= '1';
                                s2cenemy_bullet_x <= s2cenemy_x - ENEMY_BULLET_WIDTH;
                                s2cenemy_bullet_y <= s2cenemy_y + (ENEMY_HEIGHT / 2) - (ENEMY_BULLET_HEIGHT / 2); -- Set the bullet_y initial position to the top of the enemy
                            -- End of added lines
                            else
                                s2cenemy_shoot_bullet <= '0';
                                s2cenemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                            end if;
                            -- Check for collision with aircraft
                            if (s2cenemy_bullet_x >= x and s2cenemy_bullet_x < x + SIZE and s2cenemy_bullet_y >= y and s2cenemy_bullet_y < y + SIZE and aircraft_alive = '1') then
                                aircraft_alive <= '0'; -- Aircraft is hit
                                s2cenemy_shoot_bullet <= '0'; -- Enemy bullet disappears
                                s2cenemy_bullet_x <= -ENEMY_BULLET_WIDTH; -- Set the enemy bullet's position off-screen
                            end if;
                    --s2c enemy_bullet_movement_process END*/
                      
              else
            end if;
        end if;
    end if;
end process;

--display
process (hcount, vcount, x, y, bullet_x, bullet_y)
begin
    if ((hcount >= H_START and hcount < H_END) and (vcount >= V_START and vcount < V_TOTAL)) then
        --bullet
        if (hcount >= bullet_x and hcount < bullet_x + BULLET_WIDTH and vcount >= bullet_y and vcount < bullet_y + BULLET_HEIGHT) then
            color <= C_White;
        --enemy
        elsif (enemy_x <= hcount and hcount < enemy_x + ENEMY_HEIGHT and enemy_y < vcount and vcount < enemy_y + ENEMY_WIDTH and enemy_alive = '1') then
            color <= C_blue;
        elsif (hcount >= enemy_bullet_x and hcount < enemy_bullet_x + ENEMY_BULLET_WIDTH and vcount >= enemy_bullet_y and vcount < enemy_bullet_y + ENEMY_BULLET_HEIGHT) then
            color <= C_Yellow;
        elsif (s2aenemy_x <= hcount and hcount < s2aenemy_x + ENEMY_HEIGHT and s2aenemy_y < vcount and vcount < s2aenemy_y + ENEMY_WIDTH and s2aenemy_alive = '1') then
            color <= C_blue;
        elsif (hcount >= s2aenemy_bullet_x and hcount < s2aenemy_bullet_x + ENEMY_BULLET_WIDTH and vcount >= s2aenemy_bullet_y and vcount < s2aenemy_bullet_y + ENEMY_BULLET_HEIGHT) then
            color <= C_Yellow;
        elsif (s2benemy_x <= hcount and hcount < s2benemy_x + ENEMY_HEIGHT and s2benemy_y < vcount and vcount < s2benemy_y + ENEMY_WIDTH and s2benemy_alive = '1') then
            color <= C_blue;
        elsif (hcount >= s2benemy_bullet_x and hcount < s2benemy_bullet_x + ENEMY_BULLET_WIDTH and vcount >= s2benemy_bullet_y and vcount < s2benemy_bullet_y + ENEMY_BULLET_HEIGHT) then
            color <= C_Yellow;
        elsif (s2cenemy_x <= hcount and hcount < s2cenemy_x + ENEMY_HEIGHT and s2cenemy_y < vcount and vcount < s2cenemy_y + ENEMY_WIDTH and s2cenemy_alive = '1') then
                color <= C_blue;
        elsif (hcount >= s2cenemy_bullet_x and hcount < s2cenemy_bullet_x + ENEMY_BULLET_WIDTH and vcount >= s2cenemy_bullet_y and vcount < s2cenemy_bullet_y + ENEMY_BULLET_HEIGHT) then
                color <= C_Yellow;
        -- square (aircraft)
        elsif (x <= hcount and hcount < x + SIZE and y < vcount and vcount < y + SIZE and aircraft_alive = '1') then
            color <= C_Red;
        else
            color <= C_BLACK;
        end if;
    else
        color <= C_BLACK;
    end if;
end process;

process (color)
begin
case(color) is
    when C_Black =>
        red <= "0000"; green <= "0000";
        blue <= "0000";
    when C_Green =>
        red <= "0000"; green <= "1000";
        blue <= "0000";
    when C_Blue =>
        red <= "0000"; green <= "0000";
        blue <= "1111";
    when C_Red =>
        red <= "1111"; green <= "0000";
        blue <= "0000";
    when C_White =>
        red <= "1111"; green <= "1111";
        blue <= "1111";
    when C_Yellow =>
        red <= "1111"; green <= "1111";
        blue <= "0000";
    when others =>
        red <= "0000"; green <= "0000";
        blue <= "0000";
    end case;
end process; 

end Behavioral;