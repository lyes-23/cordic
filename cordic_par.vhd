entity cordic_par is
    port(
        ck          : in std_logic; 
        raz         : in std_logic;
        data        : IN std_logic;  -- Serial input for a
        rok_nxy_p   : IN  std_logic; -- Write pulse to load serial data
        wok_nxy_p   : IN std_logic;  -- Done signal when process is complete
        rd_nxy_p    : OUT std_logic; -- Done signal when process is complete
        wr_nxy_p    : OUT std_logic; -- Done signal when process is complete
        a_p         : OUT  std_logic_vector(7 DOWNTO 0); -- Parallel output for a
        x_p         : OUT  std_logic_vector(7 DOWNTO 0); -- Parallel output for x
        y_p         : OUT  std_logic_vector(7 DOWNTO 0)  -- Parallel output for y
    );
    end cordic_par;
    
    ARCHITECTURE vhd OF cordic_par IS 
    

        SIGNAL i, n_i : std_logic_vector(3 downto 0);
        SIGNAL n_a_p, n_x_p, n_y_p, tmp_a_p, tmp_x_p, tmp_y_p: std_logic_vector(7 downto 0);  
        signal n_rd_nxy_p : std_logic;
      

    
    begin 

    
    update_counter: process(ck)
    begin 
    if ((ck = '1') AND NOT(ck'STABLE) ) then 
        if(raz = '0' ) then 
            i <= "0000";
            tmp_a_p <= (others => '0');
            tmp_x_p <= (others => '0');
            tmp_y_p <= (others => '0');
            rd_nxy_p <= '0';

        else
            tmp_a_p  <= n_a_p;
            tmp_x_p  <= n_x_p;
            tmp_y_p  <= n_y_p;
            rd_nxy_p <= n_rd_nxy_p;
            wr_nxy_p <= n_rd_nxy_p;
            i <= n_i;
        end if; 
    end if;
    end process update_counter; 
    
    n_i <= i + 1 when rok_nxy_p or rd_nxy_p else "0000";
    n_rd_nxy_p <= '1'   when   i = "0111" else '0';

    n_a_p<= tmp_a_p(6 downto 0) & a when i <= "0111" else tmp_a_p;
    n_x_p<= tmp_x_p(6 downto 0) & x when i <= "0111" else tmp_x_p;
    n_y_p<= tmp_y_p(6 downto 0) & y when i <= "0111" else tmp_y_p;

    a_p         <= tmp_a_p when  i="1000" else "00000000" ;
    x_p         <= tmp_x_p  when i="1000" else "00000000" ;
    y_p         <= tmp_y_p  when i="1000" else "00000000" ;

    
    END vhd;
    