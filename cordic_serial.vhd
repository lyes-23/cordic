entity cordic_serial is 
port(
    ck     : in std_logic; 
    raz : in std_logic;

    nx_p    : in std_logic_vector(7 downto 0);
    ny_p    : in std_logic_vector(7 downto 0); 

    rok_nxy_p         : in std_logic; 

    rd_nxy_p : out std_logic;
    data_x           : out std_logic; 
    data_y           : out std_logic       
);
end cordic_serial; 

ARCHITECTURE vhd OF cordic_serial IS 

    SIGNAL n_send, send, comp, n_wait0, wait0: std_logic;
    SIGNAL counter,n_counter : std_logic_vector(2 downto 0);

begin 

    
    n_wait0  <= (wait0 and  not rok_nxy_p) or (send and comp);
    n_send  <= (send and not comp )   or (wait0 and rok_nxy_p );

FSM : process(ck)
begin 
if ((ck = '1') AND NOT(ck'STABLE) ) then 
    if(raz = '0') then 
    wait0 <= '1';
    send <= '0'; 
    else
    wait0 <= n_wait0;
    send <= n_send; 
    end if;
end if; 
end process FSM; 

rd_nxy_p <= send;


n_counter  <= "000"              when wait0
              else counter + 1   when send
              else counter;

update_counter: process(ck)
begin 
if ((ck = '1') AND NOT(ck'STABLE) ) then 
    counter <= n_counter;
end if; 
end process update_counter; 

comp <= '1' when counter = "111" else
        '0';

data_x <= nx_p(7)       when counter = "000" else
          nx_p(6)       when counter = "001" else
          nx_p(5)       when counter = "010" else
          nx_p(4)       when counter = "011" else
          nx_p(3)       when counter = "100" else
          nx_p(2)       when counter = "101" else
          nx_p(1)       when counter = "110" else
          nx_p(0);      

data_y <= ny_p(7)       when counter = "000" else
          ny_p(6)       when counter = "001" else
          ny_p(5)       when counter = "010" else
          ny_p(4)       when counter = "011" else
          ny_p(3)       when counter = "100" else
          ny_p(2)       when counter = "101" else
          ny_p(1)       when counter = "110" else
          ny_p(0);     


END vhd; 