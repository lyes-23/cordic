entity cordic_par is
    port(
        ck          : in std_logic; 
        nreset      : in std_logic;
        a           : IN std_logic;  -- Serial input for a
        x           : IN std_logic;  -- Serial input for x
        y           : IN std_logic;  -- Serial input for y
        wr_axy_p    : IN  std_logic; -- Write pulse to load serial data
        wok_axy_p   : OUT std_logic; -- Done signal when process is complete
        a_p         : OUT  std_logic_vector(7 DOWNTO 0); -- Parallel output for a
        x_p         : OUT  std_logic_vector(7 DOWNTO 0); -- Parallel output for x
        y_p         : OUT  std_logic_vector(7 DOWNTO 0)  -- Parallel output for y
    );
    end cordic_par;
    
    ARCHITECTURE vhd OF cordic_par IS 
    

        SIGNAL i, n_i : std_logic_vector(2 downto 0);
        SIGNAL n_a_p, n_x_p, n_y_p, tmp_a_p, tmp_x_p, tmp_y_p: std_logic_vector(7 downto 0);  
        signal n_wok_axy_p : std_logic;
      

    
    begin 

    
    update_counter: process(ck)
    begin 
    if ((ck = '1') AND NOT(ck'STABLE) ) then 
        if(nreset = '1' or not(wr_axy_p)) then 
            i <= "000";
            tmp_a_p <= (others => '0');
            tmp_x_p <= (others => '0');
            tmp_y_p <= (others => '0');
            
        else
            tmp_a_p<= n_a_p;
            tmp_x_p<= n_x_p;
            tmp_y_p<= n_y_p;
            wok_axy_p <= n_wok_axy_p;
            i <= n_i;
        end if; 
    end if;
    end process update_counter; 
    
    n_i <= i + 1 when wr_axy_p else "000";
    n_wok_axy_p <= '1'   when   n_i = "111" else '0';

    n_a_p<= tmp_a_p(6 downto 0) & a when i <= "111" else tmp_a_p;
    n_x_p<= tmp_x_p(6 downto 0) & x when i <= "111" else tmp_x_p;
    n_y_p<= tmp_y_p(6 downto 0) & y when i <= "111" else tmp_y_p;

    a_p         <= tmp_a_p ;
    x_p         <= tmp_x_p ;
    y_p         <= tmp_y_p ;

    
    END vhd;
    