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
        SIGNAL n_a_p, n_x_p, n_y_p : std_logic_vector(7 downto 0);  
        signal n_wok_axy_p : std_logic;
      

    
    begin 

    

    -- Serial to parallel logic for 'a'
    n_a_p(0) <= a        when wr_axy_p = '1' and i = "000" else n_a_p(0);
    n_a_p(1) <= n_a_p(0) when wr_axy_p = '1' and i = "001" else n_a_p(1);
    n_a_p(2) <= n_a_p(1) when wr_axy_p = '1' and i = "010" else n_a_p(2);
    n_a_p(3) <= n_a_p(2) when wr_axy_p = '1' and i = "011" else n_a_p(3);
    n_a_p(4) <= n_a_p(3) when wr_axy_p = '1' and i = "100" else n_a_p(4);
    n_a_p(5) <= n_a_p(4) when wr_axy_p = '1' and i = "101" else n_a_p(5);
    n_a_p(6) <= n_a_p(5) when wr_axy_p = '1' and i = "110" else n_a_p(6);
    n_a_p(7) <= a        when wr_axy_p = '1' and i = "111" else n_a_p(7);
    
    -- Serial to parallel logic for 'x'
    n_x_p(0) <= x        when wr_axy_p = '1' and i = "000" else n_x_p(0);
    n_x_p(1) <= n_x_p(0) when wr_axy_p = '1' and i = "001" else n_x_p(1);
    n_x_p(2) <= n_x_p(1) when wr_axy_p = '1' and i = "010" else n_x_p(2);
    n_x_p(3) <= n_x_p(2) when wr_axy_p = '1' and i = "011" else n_x_p(3);
    n_x_p(4) <= n_x_p(3) when wr_axy_p = '1' and i = "100" else n_x_p(4);
    n_x_p(5) <= n_x_p(4) when wr_axy_p = '1' and i = "101" else n_x_p(5);
    n_x_p(6) <= n_x_p(5) when wr_axy_p = '1' and i = "110" else n_x_p(6);
    n_x_p(7) <= x        when wr_axy_p = '1' and i = "111" else n_x_p(7);

    -- Serial to parallel logic for 'y'
    n_y_p(0) <= y        when wr_axy_p = '1' and i = "000" else n_y_p(0);
    n_y_p(1) <= n_y_p(0) when wr_axy_p = '1' and i = "001" else n_y_p(1);
    n_y_p(2) <= n_y_p(1) when wr_axy_p = '1' and i = "010" else n_y_p(2);
    n_y_p(3) <= n_y_p(2) when wr_axy_p = '1' and i = "011" else n_y_p(3);
    n_y_p(4) <= n_y_p(3) when wr_axy_p = '1' and i = "100" else n_y_p(4);
    n_y_p(5) <= n_y_p(4) when wr_axy_p = '1' and i = "101" else n_y_p(5);
    n_y_p(6) <= n_y_p(5) when wr_axy_p = '1' and i = "110" else n_y_p(6);
    n_y_p(7) <= y        when wr_axy_p = '1' and i = "111" else n_y_p(7);
    
    update_counter: process(ck)
    begin 
    if ((ck = '1') AND NOT(ck'STABLE) ) then 
        if(nreset = '1') then 
        i <= "0";
        a_p<="00000000";
        x_p<="00000000";
        y_p<="00000000";
        else
        i <= n_i;
        a_p<= n_a_p;
        x_p<= n_x_p;
        y_p<= n_y_p;
        wok_axy_p <= n_wok_axy_p;
    end if; 
    end if;
    end process update_counter; 
    

    n_i <= i + 1 when wr_axy_p else "000";
    n_wok_axy_p <= '1' when i = "111" else '0';
    
    END vhd;
    