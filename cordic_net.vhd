ENTITY cordic_net IS
PORT(
    ck          : IN  std_logic;
    raz         : IN  std_logic;

    rok_arg     : IN  std_logic;
    wok_res     : IN  std_logic;

    arg0         : IN std_logic_vector(7 downto 0);  
               
    rd_arg      : OUT std_logic;
    wr_res      : OUT std_logic;
    
    res         : OUT std_logic_vector(7 DOWNTO 0)
    
);
END cordic_net;

ARCHITECTURE vhd OF cordic_net IS

    SIGNAL mkc  : std_logic_vector(1 downto 0); -- multiply KC
    SIGNAL cmd  : std_logic_vector(2 downto 0); -- command algo
    SIGNAL i    : std_logic_vector(2 downto 0); -- dichotomous search counter
    
    SIGNAL rd_to_tto   : std_logic;  -- Control signal for write from cordic_ctl to two_to_one
    SIGNAL wr_to_ctl   : std_logic;  -- Control signal for write from one_to_three to cordic_ctl
    SIGNAL wr_to_tto   : std_logic;  -- Write control signal for two_to_one component
    SIGNAL rd_to_ctl   : std_logic;  -- Read control signal from two_to_one to cordic_ctl

    SIGNAL a_p_v, x_p_v, y_p_v: std_logic_vector(7 downto 0); -- parallel vectors coming from _par
    SIGNAL nx_p_v, ny_p_v : std_logic_vector(7 downto 0); -- result of CORDIC operation
    


    COMPONENT one_to_three
    PORT(
        ck     : in std_logic; 
        raz    : in std_logic;
    
        data_in : in std_logic_vector(7 downto 0);
    
        x_p    : out std_logic_vector(7 downto 0);
        y_p    : out std_logic_vector(7 downto 0); 
        a_p    : out std_logic_vector(7 downto 0); 
    
        rok_nxy_p        : in std_logic; 
        rd_nxy_p         : out std_logic;
    
        wok_axy_p        : in std_logic;
        wr_axy_p         : out std_logic
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

    COMPONENT two_to_one
    PORT(
        ck     : in std_logic; 
        raz    : in std_logic;
    
        nx_p    : in std_logic_vector(7 downto 0);
        ny_p    : in std_logic_vector(7 downto 0); 
    
        rok_nxy_p        : in std_logic; 
        rd_nxy_p         : out std_logic;
    
        wok_axy_p        : in std_logic;
        wr_axy_p         : out std_logic;
    
        data_out           : out std_logic_vector(7 downto 0) 
    );
    END COMPONENT;

BEGIN

    par : one_to_three
    PORT MAP (
        ck          => ck,
        raz         => raz,
        data_in     => arg0,  -- Data input for one_to_three
        x_p         => x_p_v, -- Resulting x from parallel processing
        y_p         => y_p_v, -- Resulting y from parallel processing
        a_p         => a_p_v, -- Resulting a from parallel processing
        rok_nxy_p   => rok_arg, -- Control signal for rd from cordic_ctl in
        rd_nxy_p    => rd_arg, -- Control signal to cordic_ctl      out

        wok_axy_p   => wr_to_ctl, -- Write Okay control for cordic_ctl in
        wr_axy_p    => rd_to_tto -- Write control to cordic_ctl out 
        );

    ctl : cordic_ctl 
    PORT MAP (
        ck          => ck         ,
        raz         => raz        ,
                       
        wr_axy_p    =>  rd_to_ctl, -- going to _serial    in
        a_p         => a_p_v      ,   -- coming from three to one
        wok_axy_p   =>  wr_to_tto, -- comming from _serial out 
                       
        rd_nxy_p    => rd_to_tto,   --in  
        rok_nxy_p   => wr_to_ctl  ,  -- out
                       
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

    serial : two_to_one 
    PORT MAP (
        ck          => ck,  
        raz         => raz,

        nx_p        => nx_p_v,      
        ny_p        => ny_p_v,    

        rok_nxy_p   => wr_to_tto,   --in
        rd_nxy_p    => rd_to_ctl, --out
        wok_axy_p   => wok_res, 

        wr_axy_p    => wr_res,      
        data_out    => res          

    );

END vhd;
