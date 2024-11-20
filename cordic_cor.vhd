ENTITY cordic_cor IS
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
END cordic_cor;

ARCHITECTURE vhd OF cordic_cor IS

    SIGNAL
        n_get,  get,                -- get coordinates and angle
        n_norm, norm,               -- normalization
        n_calc, calc,               -- calcul
        n_mkc,  mkc,                -- multiply KC
        n_place,place,              -- place in good quadrant
        n_put,  put,                -- put result
        a_lt_0,                     -- a lower than 0
        quadrant_0                  -- 1 quand a est dans le quadrant 0
    : std_logic;

    SIGNAL
        n_quadrant, quadrant        -- numéro du quadrant
    : std_logic_vector(1 downto 0);

    SIGNAL
        n_i, i                      -- compteur de recherche dichotomique
    : std_logic_vector(2 downto 0);

    SIGNAL
        n_x,    x,                  -- coordonnée x
        n_y,    y,                  -- coordonnée y
        n_a,    a,                  -- angle
        n_xkc,  xkc,                -- x * KC
        n_ykc,  ykc,                -- y * KC
        atan,                       -- arctangeante de l'angle de rotation
        a_mpidiv2,                  -- a - PI/2
        x_sra_1, y_sra_1,           -- x >> 1 et y >> 1
        x_sra_2, y_sra_2,           -- x >> 2 et y >> 2
        x_sra_3, y_sra_3,           -- x >> 3 et y >> 3
        x_sra_4, y_sra_4,           -- x >> 4 et y >> 4
        x_sra_5, y_sra_5,           -- x >> 5 et y >> 5
        x_sra_6, y_sra_6,           -- x >> 6 et y >> 6
        x_sra_7, y_sra_7,           -- x >> 7 et y >> 7
        x_sra_i, y_sra_i            -- x >> i et y >> i
    : std_logic_vector(15 downto 0);

BEGIN

-------------------------------------------------------------------------------
-- FSM
-------------------------------------------------------------------------------

    -- FSM transition

    n_get       <= (get  AND NOT wr_axy_p)
                OR (put  AND rd_nxy_p)
                ;
    n_norm      <= (get  AND wr_axy_p)
                OR (norm AND NOT quadrant_0)
                ;
    n_calc      <= (norm AND quadrant_0)
                OR (calc AND NOT (i = 7))
                ;
    n_mkc       <= (calc AND (i = 7))
                OR (mkc  AND NOT (i = 2))
                ;
    n_place     <= (mkc  AND (i = 2))
                ;
    n_put       <= (place)
                OR (put  AND NOT rd_nxy_p)
                ;

    FSM : PROCESS (ck) begin
    if ((ck = '1') AND NOT(ck'STABLE) )
    then
        if (raz = '0') then
            get   <= '1';
            norm  <= '0';
            calc  <= '0';
            mkc   <= '0';
            place <= '0';
            put   <= '0';
        else
            get   <= n_get   ;
            norm  <= n_norm  ;
            calc  <= n_calc  ;
            mkc   <= n_mkc   ;
            place <= n_place ;
            put   <= n_put   ;
        end if;
    end if;
    end process FSM;

    -- Sorties issues de l'automate

    wok_axy_p   <=  get;
    rok_nxy_p   <=  put;

-------------------------------------------------------------------------------
-- Compteurs de l'algorithme et calcul de l'angle de rotation@
-------------------------------------------------------------------------------

    -- Compteurs de normalisation de l'angle : quadrant est le numéro du quadrant

    n_quadrant  <= "00"           when get
              else quadrant + 1   when norm AND NOT quadrant_0
              else quadrant;

    -- ROM with arctan(2-i)

    atan        <= x"0065" when i = 0     -- atan(2^-0)
              else x"003B" when i = 1     -- atan(2^-1)
              else x"001F" when i = 2     -- atan(2^-2)
              else x"0010" when i = 3     -- atan(2^-3)
              else x"0008" when i = 4     -- atan(2^-4)
              else x"0004" when i = 5     -- atan(2^-5)
              else x"0002" when i = 6     -- atan(2^-6)
              else x"0001";               -- atan(2^-7)

    -- Calcul de l'angle : recherche par dichotomie

    a_mpidiv2   <= a - x"00C9";
    quadrant_0  <= a_mpidiv2(15);
    a_lt_0      <= a(15);    -- 1 si a est négatif (signe de a)

    n_a         <= a_p & "00" when get                     -- init
              else a_mpidiv2  when norm AND NOT quadrant_0 -- a - PI/2
              else a - atan   when calc AND NOT a_lt_0     -- trop grand
              else a + atan   when calc AND a_lt_0         -- trop petit
              else a;                                      -- stable

    -- Compteurs de la dichotomie et de la normalisation de l'angle

    n_i         <= "000"      when get                     -- init
              else i + 1      when calc or mkc             -- inc 
              else i ;                                     -- stable


    CTL : PROCESS (ck) begin
    if ((ck = '1') AND NOT(ck'STABLE) )
    then
       i        <= n_i        ;
       quadrant <= n_quadrant ;
       a        <= n_a        ;
    end if;
    end process CTL;

-------------------------------------------------------------------------------
-- Chemin de données
-------------------------------------------------------------------------------

    -- Shifters : x_sra_i <= x << i et y_sra_i <= y << i

    x_sra_1     <= x(15) &       x(15 downto 1);
    x_sra_2     <= x(15) & x_sra_1(15 downto 1);
    x_sra_3     <= x(15) & x_sra_2(15 downto 1);
    x_sra_4     <= x(15) & x_sra_3(15 downto 1);
    x_sra_5     <= x(15) & x_sra_4(15 downto 1);
    x_sra_6     <= x(15) & x_sra_5(15 downto 1);
    x_sra_7     <= x(15) & x_sra_6(15 downto 1);
    x_sra_i     <= x_sra_1 when i = 1
              else x_sra_2 when i = 2
              else x_sra_3 when i = 3
              else x_sra_4 when i = 4
              else x_sra_5 when i = 5
              else x_sra_6 when i = 6
              else x_sra_7 when i = 7
              else x;

    y_sra_1     <= y(15) &       y(15 downto 1);
    y_sra_2     <= y(15) & y_sra_1(15 downto 1);
    y_sra_3     <= y(15) & y_sra_2(15 downto 1);
    y_sra_4     <= y(15) & y_sra_3(15 downto 1);
    y_sra_5     <= y(15) & y_sra_4(15 downto 1);
    y_sra_6     <= y(15) & y_sra_5(15 downto 1);
    y_sra_7     <= y(15) & y_sra_6(15 downto 1);
    y_sra_i     <= y_sra_1 when i = 1
              else y_sra_2 when i = 2
              else y_sra_3 when i = 3
              else y_sra_4 when i = 4
              else y_sra_5 when i = 5
              else y_sra_6 when i = 6
              else y_sra_7 when i = 7
              else y;

    -- produits des coordonnées de rotation par KC

    n_xkc       <= x_sra_6 + x_sra_5 when mkc AND i = 0
              else xkc     + x_sra_4 when mkc AND i = 1
              else xkc     + x_sra_1 when mkc AND i = 2
              else xkc;

    n_ykc       <= y_sra_6 + y_sra_5 when mkc AND i = 0
              else ykc     + y_sra_4 when mkc AND i = 1
              else ykc     + y_sra_1 when mkc AND i = 2
              else ykc;

    -- coordonnées

    n_x         <= x_p(7) & x_p & "0000000" when get                  -- init
              else x - y_sra_i              when calc  AND NOT a_lt_0 -- au dessus
              else x + y_sra_i              when calc  AND a_lt_0     -- en dessous
              else xkc                      when place AND (quadrant = 0)
              else -ykc                     when place AND (quadrant = 1)
              else -xkc                     when place AND (quadrant = 2)
              else ykc                      when place AND (quadrant = 3)
              else x;

    n_y         <= y_p(7) & y_p & "0000000" when get                  -- init
              else y + x_sra_i              when calc  AND NOT a_lt_0 -- au dessus
              else y - x_sra_i              when calc  AND a_lt_0     -- en dessous
              else ykc                      when place AND (quadrant = 0) 
              else xkc                      when place AND (quadrant = 1)
              else -ykc                     when place AND (quadrant = 2)
              else -xkc                     when place AND (quadrant = 3)
              else y;

    DP : PROCESS (ck) begin
    if ((ck = '1') AND NOT(ck'STABLE) )
    then
       x     <= n_x     ;
       y     <= n_y     ;
       xkc   <= n_xkc   ;
       ykc   <= n_ykc   ;
    end if;
    end process DP;

    -- Sorties du chemin de données

    nx_p        <=  x(14 downto 7);
    ny_p        <=  y(14 downto 7);

END vhd;
