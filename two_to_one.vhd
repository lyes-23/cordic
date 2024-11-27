entity two_to_one is 
port(
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
end two_to_one; 

ARCHITECTURE vhd OF two_to_one IS 

    SIGNAL n_send, send, comp, n_wait0, wait0: std_logic;
    SIGNAL counter,n_counter : std_logic;

begin 

    
    n_wait0  <= (wait0 and  not rok_nxy_p) or (send and counter);
    n_send  <= (send and not counter )   or (wait0 and rok_nxy_p );

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

rd_nxy_p <= wait0;
wr_axy_p <= send;


n_counter  <= "0"              when wait0
              else counter + 1  when send
              else counter;

update_counter: process(ck)
begin 
if ((ck = '1') AND NOT(ck'STABLE) ) then 
    counter <= n_counter;
end if; 
end process update_counter; 



data_out <= nx_p when  not counter else 
            ny_p when counter      else
            x"00";


END vhd; 