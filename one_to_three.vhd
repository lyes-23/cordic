entity one_to_three is 
port(
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
end one_to_three; 

ARCHITECTURE vhd OF one_to_three IS 

    SIGNAL n_send, send, comp, n_wait0, wait0, n_read0, read0: std_logic;
    SIGNAL counter,n_counter : std_logic_vector(1 downto 0);
    signal temp_x, temp_y, temp_a,n_temp_x, n_temp_y, n_temp_a : std_logic_vector(7 downto 0);

begin 

    


FSM : process(ck)
begin 
if ((ck = '1') AND NOT(ck'STABLE) ) then 
    if(raz = '0') then 
    wait0 <= '1';
    send <= '0'; 
    read0 <= '0';
    temp_x <=  "00000000";
    temp_y <=  "00000000";
    temp_a <=  "00000000";
    else
    wait0 <= (wait0 and not rok_nxy_p) or (send and wok_axy_p);
    send  <= (send and not wok_axy_p) or (read0 and comp);
    read0 <= (read0 AND not comp) or (wait0 AND rok_nxy_p);
    temp_x <=  n_temp_x;
    temp_y <=  n_temp_y;
    temp_a <=  n_temp_a;
    end if;
end if; 
end process FSM; 

rd_nxy_p <= wait0;
wr_axy_p <= send;


n_counter  <= "00"              when wait0 or send
              else counter + 1  when read0
              else "00";

comp       <= '1' when counter = "10" else '0';

update_counter: process(ck)
begin 
if ((ck = '1') AND NOT(ck'STABLE) ) then 
    counter <= n_counter;
   
end if; 
end process update_counter; 
 
 n_temp_x <= data_in when counter = "00" and rok_nxy_p else temp_x;
 n_temp_y <= data_in when counter = "01" and rok_nxy_p else temp_y;
 n_temp_a <= data_in when counter = "10" and rok_nxy_p else temp_a;

 x_p <= temp_x when send else "00000000";
 y_p <= temp_y when send else "00000000";
 a_p <= temp_a when send else "00000000";




END vhd; 