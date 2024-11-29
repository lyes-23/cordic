ENTITY cordic_tb IS
PORT(
    ck          : IN  std_logic;
    nreset      : IN  std_logic;
    ko_p        : OUT std_logic
);
END cordic_tb;

ARCHITECTURE vhd OF cordic_tb IS

    -- By convention, I choose the signal's name according to the port's name that produces it.
    -- Thus, any output port of a component (e.g. wr_arg_p) is connected to a signal with the same
    -- name, but without _p (port marker) (e.g. wr_arg_p => wr_arg)
    SIGNAL wr_arg  : std_logic;
    SIGNAL argd    : std_logic_vector(7 DOWNTO 0);
    SIGNAL rd_arg  : std_logic;
    SIGNAL rd_res  : std_logic;
    SIGNAL res     : std_logic_vector(7 DOWNTO 0);
    SIGNAL wr_res  : std_logic;

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

    COMPONENT cordic_net
    PORT(
        ck          : IN  std_logic;
        raz      : IN  std_logic;

        rd_arg    : OUT std_logic;
        arg0       : IN  std_logic_vector(7 DOWNTO 0);
        rok_arg   : IN  std_logic;

        wr_res    : OUT std_logic;
        res       : OUT std_logic_vector(7 DOWNTO 0);
        wok_res   : IN  std_logic

    );

    END COMPONENT;

BEGIN

    data : cordic_data
    PORT MAP (
        ck          => ck        ,
        nreset      => nreset       ,

        wr_arg_p    => wr_arg    ,
        arg_p       => argd      ,
        wok_arg_p   => rd_arg    ,

        rd_res_p    => rd_res    ,
        res_p       => res       ,
        rok_res_p   => wr_res    ,

        ko_p        => ko_p
    );

    core : cordic_net
    PORT MAP (
        ck          => ck        ,
        raz      => nreset       ,

        rd_arg    => rd_arg    ,
        arg0       => argd      ,
        rok_arg   => wr_arg    ,

        wr_res    => wr_res    ,
        res       => res       ,
        wok_res   => rd_res
    
    );
END vhd;
