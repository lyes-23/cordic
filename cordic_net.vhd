ENTITY cordic_net IS
PORT(
    ck          : IN  std_logic;
    raz         : IN  std_logic;

    wr_axy_p    : IN  std_logic;
    a_p         : IN  std_logic_vector(7 DOWNTO 0);
    x_p         : IN  std_logic_vector(7 DOWNTO 0);
    y_p         : IN  std_logic_vector(7 DOWNTO 0);
    wok_axy_p   : OUT std_logic;

    rd_nxy_p    : IN  std_logic;
    nx_p        : OUT std_logic_vector(7 DOWNTO 0);
    ny_p        : OUT std_logic_vector(7 DOWNTO 0);
    rok_nxy_p   : OUT std_logic
);
END cordic_net;

ARCHITECTURE vhd OF cordic_net IS

    SIGNAL mkc  : std_logic_vector(1 downto 0); -- multiply KC
    SIGNAL cmd  : std_logic_vector(2 downto 0); -- command algo
    SIGNAL i    : std_logic_vector(2 downto 0); -- compteur de recherche dichotomique

    COMPONENT cordic_ctl
    PORT(
        ck          : IN  std_logic;
        raz         : IN  std_logic;
        
        wr_axy_p    : IN  std_logic;
        a_p         : IN  std_logic_vector(7 DOWNTO 0);
        wok_axy_p   : OUT std_logic;
        
        rd_nxy_p    : IN  std_logic;
        rok_nxy_p   : OUT std_logic;
        
        mkc_p       : OUT std_logic_vector(1 DOWNTO 0);
        cmd_p       : OUT std_logic_vector(2 DOWNTO 0);
        i_p         : OUT std_logic_vector(2 DOWNTO 0)
    );
    END COMPONENT;

    COMPONENT cordic_dp
    PORT(
        ck          : IN  std_logic;
        
        x_p         : IN  std_logic_vector(7 DOWNTO 0);
        y_p         : IN  std_logic_vector(7 DOWNTO 0);
        
        nx_p        : OUT std_logic_vector(7 DOWNTO 0);
        ny_p        : OUT std_logic_vector(7 DOWNTO 0);
        
        mkc_p       : IN  std_logic_vector(1 DOWNTO 0);
        cmd_p       : IN  std_logic_vector(2 DOWNTO 0);
        i_p         : IN  std_logic_vector(2 DOWNTO 0)
    );
    END COMPONENT;

BEGIN

    ctl : cordic_ctl 
    PORT MAP (
        ck          => ck         ,
        raz         => raz        ,
                       
        wr_axy_p    => wr_axy_p   ,
        a_p         => a_p        ,
        wok_axy_p   => wok_axy_p  ,
                       
        rd_nxy_p    => rd_nxy_p   ,
        rok_nxy_p   => rok_nxy_p  ,
                       
        mkc_p       => mkc        ,
        cmd_p       => cmd        ,
        i_p         => i
    );

    dp : cordic_dp 
    PORT MAP (
        ck          => ck         ,
        
        x_p         => x_p        ,
        y_p         => y_p        ,
                       
        nx_p        => nx_p       ,
        ny_p        => ny_p       ,
                       
        mkc_p       => mkc        ,
        cmd_p       => cmd        ,
        i_p         => i
    );

END vhd;
