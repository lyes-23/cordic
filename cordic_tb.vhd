ENTITY cordic_tb IS
PORT(
    ck          : IN  std_logic;
    nreset      : IN  std_logic;
    ko_p        : OUT std_logic
);
END cordic_tb;

ARCHITECTURE vhd OF cordic_tb IS

    SIGNAL wr_arg_n  : std_logic;
    SIGNAL arg_n    : std_logic_vector(7 DOWNTO 0);
    SIGNAL rd_arg_n  : std_logic;
    SIGNAL rd_res_n  : std_logic;
    SIGNAL res_n     : std_logic_vector(7 DOWNTO 0);
    SIGNAL wr_res_n  : std_logic;


    COMPONENT cordic_net
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
    END COMPONENT;


    COMPONENT cordic_data
    PORT(
        ck          : IN  std_logic;
        nreset      : IN  std_logic;

        wr_arg_p    : OUT std_logic;
        arg_p       : OUT std_logic_vector(7 DOWNTO 0);
        wok_arg_p   : IN  std_logic;

        rd_res_p    : OUT std_logic;
        res_p       : IN  std_logic_vector(7 DOWNTO 0);
        rok_res_p   : IN   std_logic;

        ko_p        : OUT std_logic


    );
    END COMPONENT;




BEGIN

    data : cordic_data   -- okay
    PORT MAP (
        ck          => ck        ,
        nreset      => nreset    ,

        wr_arg_p    => wr_arg_n    , 
        arg_p       => arg_n     , --ok
        wok_arg_p   => rd_arg_n  , --ok

        rd_res_p    => rd_res_n    , --ok
        res_p       => res_n     , --ok
        rok_res_p   => wr_res_n  ,

        ko_p        => ko_p
    );

    NET: cordic_net 
    PORT MAP (
        ck          => ck       ,
        raz         => nreset   ,
    
        rok_arg     => wr_arg_n   , --ok
        wok_res     => rd_res_n   , --ok
    
        arg0        => arg_n   , --ok
                   
        rd_arg      => rd_arg_n , --ok
        wr_res      => wr_res_n , --ok
        
        res         => res_n  --ok
    );

   
END vhd;
