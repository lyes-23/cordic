0ENTITY cordic_net IS
PORT(
    ck          : IN  std_logic;
    raz         : IN  std_logic;

    wr_axy_p    : IN  std_logic;
    a           : IN std_logic;  -- Serial input for a
    x           : IN std_logic;  -- Serial input for x
    y           : IN std_logic;  -- Serial input for y
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
    SIGNAL rd_axy_12, rd_nxy_p_21, wr_axy_p_23, rd_nxy_p_32  : std_logic; --wok of cordic_par become wr of cordic_ctl
    SIGNAL a_p_v, x_p_v, y_p_v: std_logic_vector(7 downto 0); -- the parallel vector comming from _par

    COMPONENT cordic_par
    PORT(
        ck          : IN  std_logic;
        raz         : IN  std_logic;
        
        a           : IN std_logic;  -- Serial input for a
        x           : IN std_logic;  -- Serial input for x
        y           : IN std_logic;  -- Serial input for y
        rok_axy_p   : IN  std_logic; -- Write pulse to load serial data
        rd_axy_p    : OUT std_logic; -- Done signal when process is complete
        a_p         : OUT  std_logic_vector(7 DOWNTO 0); -- Parallel output for a
        x_p         : OUT  std_logic_vector(7 DOWNTO 0); -- Parallel output for x
        y_p         : OUT  std_logic_vector(7 DOWNTO 0)  -- Parallel output for y
    );
    END COMPONENT;

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

    COMPONENT cordic_serial
    PORT(
        ck          : in std_logic; 
        raz         : in std_logic;
    
        nx_p        : in std_logic_vector(7 downto 0);
        ny_p        : in std_logic_vector(7 downto 0); 
    
        rok_nxy_p   : in std_logic; 
    
        rd_nxy_p    : out std_logic;
        data_x      : out std_logic; 
        data_y      : out std_logic   
    );
    END COMPONENT;

BEGIN

    par : cordic_par 
    PORT MAP (
        ck          => ck         ,
        raz         => raz        ,
                    
        a           => a          ,
        x           => x          ,
        y           => y          ,
                    
        rok_axy_p   => rd_nxy_p_21 , -- comming from _ctl
        rd_axy_p   => rd_axy_12    , --going to _ctl
                    
        a_p         => a_p_v      , --going to _ctl
        x_p         => x_p_v      , --going to _dp
        y_p         => y_p_v        --going to _dp
    );

    ctl : cordic_ctl 
    PORT MAP (
        ck          => ck         ,
        raz         => raz        ,
                       
        wr_axy_p    => wr_axy_p_23 , -- going to _serial 
        a_p         => a_p_v      , -- coming from _par
        wok_axy_p   => rd_nxy_p_32 , -- comming from _serial
                       
        rd_nxy_p    => rd_nxy_p_21, -- going to _par
        rok_nxy_p   => rd_axy_12  , -- comming from _par
                       
        mkc_p       => mkc        ,  --going to _dp
        cmd_p       => cmd        ,  --going to _dp
        i_p         => i             --going to _dp
    );

    dp : cordic_dp 
    PORT MAP (
        ck          => ck         ,
        
        x_p         => x_p_v      , --coming from _par
        y_p         => y_p_v      , --coming form _par
                       
        nx_p        => nx_p_v     , --going to _serial
        ny_p        => ny_p_v     , --going to _serial
                       
        mkc_p       => mkc        , --comming from_ctl
        cmd_p       => cmd        , --comming from_ctl
        i_p         => i            --comming from_ctl
    );

    serial : cordic_serial 
    PORT MAP (
        ck          => ck         ,
        raz         => raz        ,
                       
        nx_p        => nx_p_v     , -- comming from _dp
        ny_p        => ny_p_v     , -- comming from _dp

        rok_nxy_p   => wr_axy_p_23 , -- comming from _ctl                     
        rd_nxy_p    => rd_nxy_p_32 , -- going to _ctl

        data_x      => data_x     ,                  
        data_y      => data_y 
    );

END vhd;
