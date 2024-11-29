ENTITY cordic_data IS
PORT(
    ck          : IN  std_logic;
    nreset      : IN  std_logic;

    wr_arg_p    : OUT std_logic;
    arg_p       : OUT std_logic_vector(VALWD-1 DOWNTO 0);
    wok_arg_p   : IN  std_logic;

    rd_res_p    : OUT std_logic;
    res_p       : IN  std_logic_vector(VALWD-1 DOWNTO 0);
    rok_res_p   : IN  std_logic;

    ko_p        : OUT std_logic
);
END cordic_data;

ARCHITECTURE vhd OF cordic_data IS

    SIGNAL          -- FSM states
        x_p,        -- set x coordinats
        y_p,        -- set y coordinats
        a_p,        -- set the angle of rotation
        nx_p,        -- get x coordinat result
        ny_p,        -- get y coordinat result
        stop,       -- it's over
        lastpt      -- 1 when pt = address of the last filled box in ROM 
    : std_logic;

    SIGNAL
        pt          -- rom_pointer 
        : std_logic_vector(ADDRWD-1 downto 0);

    SIGNAL
        value       -- rom_value
    : std_logic_vector(VALWD-1 downto 0);

BEGIN

    REG : PROCESS (ck) begin
    if ((ck = '1') AND NOT(ck'STABLE)) then
        if (nreset = '0') then
            x_p  <= '1';
            y_p  <= '0';
            a_p  <= '0';
            nx_p  <= '0';
            ny_p  <= '0';
            stop <= '0';
            pt   <= (others=>'0');
        else
            x_p  <= (ny_p AND rok_res_p AND not lastpt)
                 OR (x_p AND not wok_arg_p);

            y_p  <= (x_p AND wok_arg_p)
                 OR (y_p AND not wok_arg_p);

            a_p  <= (y_p AND wok_arg_p)
                    OR (a_p AND not wok_arg_p);

            nx_p  <= (a_p AND wok_arg_p)
                 OR (nx_p AND not rok_res_p);
            
            ny_p  <= (nx_p AND wok_arg_p)
                OR (ny_p AND not rok_res_p);
            
            stop <= (ny_p AND rok_res_p AND lastpt)
                 OR stop;

            if ((x_p AND wok_arg_p) OR (y_p AND wok_arg_p) OR (a_p AND rok_res_p) OR (nx_p AND rok_res_p) OR (ny_p AND rok_res_p)) then
                pt   <= pt + 1;
            end if;
        end if;
    end if;
    end process REG;

    lastpt     <= (pt = LASTPT);
    wr_arg_p   <= x_p OR y_p OR a_p;
    rd_res_p   <= nx_p or ny_p;
    arg_p      <= value;
    ko_p       <= nx_p AND ny_p AND rok_res_p AND (value /= res_p);

--  #include <rom.txt> incudes a file with a generated ROM, defined as below
--  value       <= x"12"    when pt = 0
--            else x"60"    when pt = 1
--            else x"06"    when pt = 2
--            else x"00";
#   include "rom.txt"

END vhd;
