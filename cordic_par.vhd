entity cordic_par is 
port(
    ck          : in std_logic; 
    nreset      : in std_logic;
    a           : IN std_logic;
    x           : IN std_logic;
    y           : IN std_logic;

    wr_axy_p    : IN  std_logic;
    wok_axy_p   : OUT std_logic;

    a_p         : OUT  std_logic_vector(7 DOWNTO 0);
    x_p         : OUT  std_logic_vector(7 DOWNTO 0);
    y_p         : OUT  std_logic_vector(7 DOWNTO 0)
);
end cordic_par; 

ARCHITECTURE vhd OF cordic_par IS 

    SIGNAL comp   : std_logic;
    signal i, n_i : std_logic_vector(2 downto 0);
    signal n_a_p,n_x_p,n_y_p : std_logic_vector(7 downto 0);

begin 

comp <= '1' when i = "111" else
        '0';
  
update_counter: process(ck)
begin 
    if ((ck = '1') AND NOT(ck'STABLE) ) then 
        i <= n_i;
        a_p<= n_a_p;
        x_p<= n_x_p;
        y_p<= n_y_p;
    end if; 
end process update_counter; 


    n_i <= i+1     when wr_axy_p 
    else "000" ;

    wok_axy_p <= '1' when i = "111"
    else '0'; 

    

    n_a_p(0) <= a when i = "000" else '0';
    n_a_p(1) <= a when i = "001" else '0';
    n_a_p(2) <= a when i = "010" else '0';
    n_a_p(3) <= a when i = "011" else '0';
    n_a_p(4) <= a when i = "100" else '0';
    n_a_p(5) <= a when i = "101" else '0';
    n_a_p(6) <= a when i = "110" else '0';
    n_a_p(7) <= a when i = "111" else '0';

    n_x_p(0) <= x when i = "000" else '0';
    n_x_p(1) <= x when i = "001" else '0';
    n_x_p(2) <= x when i = "010" else '0';
    n_x_p(3) <= x when i = "011" else '0';
    n_x_p(4) <= x when i = "100" else '0';
    n_x_p(5) <= x when i = "101" else '0';
    n_x_p(6) <= x when i = "110" else '0';
    n_x_p(7) <= x when i = "111" else '0';

    n_y_p(0) <= y when i = "000" else '0';
    n_y_p(1) <= y when i = "001" else '0';
    n_y_p(2) <= y when i = "010" else '0';
    n_y_p(3) <= y when i = "011" else '0';
    n_y_p(4) <= y when i = "100" else '0';
    n_y_p(5) <= y when i = "101" else '0';
    n_y_p(6) <= y when i = "110" else '0';
    n_y_p(7) <= y when i = "111" else '0';



END vhd; 