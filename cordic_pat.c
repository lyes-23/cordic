#include <stdio.h>
#include <math.h>
#include <assert.h>
#include "genpat.h"
#include "alloca.h"
#include "mut.h"

// Constante générales
const PERIOD=2;

//--------------------------------------------------------------------------------------------------
// rend la date du cycle n°i ou du cycle n°i + 1 demi-cycle 
//--------------------------------------------------------------------------------------------------
#define cycle(i)        inttostr(i*PERIOD)
#define next_cycle(i)   inttostr(i*PERIOD + PERIOD/2)
#define out_cycle(i)    inttostr(i*PERIOD - PERIOD/2)

//--------------------------------------------------------------------------------------------------
// Fabriquer une chaine de caractères à partir d'un entier
//
// namealloc fait l'équivalent de strdup() mais en plus il teste que la chaine 
//           en paramètre n'a pas déjà été allouée, si oui, namealloc rend
//           le pointeur sur la chaine déjà allouée, cette opération utilise
//           un dictionnaire (table de hachage)
//
// inttostr(42)         rend un pointeur sur "42"
// inttostr(42)         rend LE MÊME pointeur sur "42"
// inttostrx(0x42,4)    rend "0x0042"
// inttostrx(0x42,1)    rend "0x2"
// inttostrx(0x42,8)    rend "0x00000042"
//--------------------------------------------------------------------------------------------------
static inline char *inttostr(int entier)
{
    char *str = (char *) alloca(32 * sizeof(char)); // allocation dans la pile
    sprintf(str, "%d", entier);
    return namealloc(str);  // utilise un dictionnaire
}

static inline char *inttostrX(int entier,int size)
{
    int mask;
    for (mask = 0; size; mask = (mask<<1) | 1, size--); 
    char *str = (char *) alloca(32 * sizeof(char)); // allocation dans la pile
    sprintf(str, "0x%0*x", size, entier & mask);
    return namealloc(str);  // utilise un dictionnaire
}

//--------------------------------------------------------------------------------------------------
// cordic_seq
//--------------------------------------------------------------------------------------------------
#define NEW(name)   name##_new
#define REG(name)   NEW(name), name
#if DEBUG
#   define LINE "------------------------------------------\n"
#   define UPD(name,arg...)   name = NEW(name); fprintf(stderr, arg #name " = %d\n", name)
#else
#   define UPD(name,arg...)   name = NEW(name)
#endif

void cordic_seq (
    
    char    wr_axy_p,
    short   a_p,
    char    x_p, 
    char    y_p, 
    char    *wok_axy_p,

    char    rd_nxy_p,
    char    *nx_p, 
    char    *ny_p,
    char    *rok_nxy_p)
{
    short F_PI = (short)((M_PI) * (1<<7));

    short ATAN[8] = {
        0x65,                 // ATAN(2^-0)
        0x3B,                 // ATAN(2^-1)
        0x1F,                 // ATAN(2^-2)
        0x10,                 // ATAN(2^-3)
        0x08,                 // ATAN(2^-4)
        0x04,                 // ATAN(2^-5)
        0x02,                 // ATAN(2^-6)
        0x01,                 // ATAN(2^-7)
    };

    // datapath registers

    static short    
        REG(i), 
        REG(q), 
        REG(x), 
        REG(y), 
        REG(a),
        REG(xkc), 
        REG(ykc); 

    // FSM states

    static char     
        REG(Get)=1,         // get coordinates and angle
        REG(Norm)=0,        // normalization
        REG(Calc)=0,        // calcul
        REG(Mkc)=0,         // multiply KC
        REG(Place)=0,       // place in good quadrant
        REG(Put)=0;         // put result

    // FSM transition
    
    NEW(Get)    =  (Get     && (wr_axy_p == 0))
                || (Put     && (rd_nxy_p))
                ;
    NEW(Norm)   =  (Get     && wr_axy_p)
                || (Norm    && (a >= F_PI/2))
                ; 
    NEW(Calc)   =  (Norm    && (a < F_PI/2))
                || (Calc    && (i != 7))
                ;
    NEW(Mkc)    =  (Calc    && (i == 7))
                || (Mkc     && (i != 2))
                ;
    NEW(Place)  =  (Mkc     && (i == 2))
                ;
    NEW(Put)    =  (Place)
                || (Put     && (rd_nxy_p == 0))
                ;
    
    // Moore generation ports

    *nx_p       = x>>7;
    *ny_p       = y>>7;
   
    *wok_axy_p  = Get ? 1 : 0;
    *rok_nxy_p  = Put ? 1 : 0;

    // Moore generation internal signals
    
    NEW(xkc)    = Mkc && (i == 0) ? (x>>6) + (x>>5)  
                : Mkc && (i == 1) ? xkc    + (x>>4)  
                : Mkc && (i == 2) ? xkc    + (x>>1)  
                : xkc;   
              
    NEW(ykc)    = Mkc && (i == 0) ? (y>>6) + (y>>5) 
                : Mkc && (i == 1) ? ykc    + (y>>4) 
                : Mkc && (i == 2) ? ykc    + (y>>1) 
                : ykc;

    NEW(i)      = Get     ? 0
                : Calc    ? (i + 1) & 7
                : Mkc     ? (i + 1) & 7 
                : i;
               
    NEW(q)      = Get                   ? 0
                : Norm && (a >= F_PI/2) ? (q + 1) & 0x3 
                : q;
               
    NEW(a)      = Get                   ? a_p<<2 
                : Norm && (a >= F_PI/2) ? (a - F_PI/2)
                : Calc && (a >= 0)      ? a - ATAN[i]
                : Calc && (a <  0)      ? a + ATAN[i]
                : a;
               
    NEW(x)      = Get                   ? ((x_p>>7)<<15) + (x_p << 7)
                : Calc && (a >= 0)      ? x - (y >> i) 
                : Calc && (a < 0)       ? x + (y >> i)
                : Place && (q == 0)     ? xkc 
                : Place && (q == 1)     ? -ykc 
                : Place && (q == 2)     ? -xkc 
                : Place && (q == 3)     ? ykc 
                : x;
               
    NEW(y)      = Get                   ? ((y_p>>7)<<15) + (y_p << 7)
                : Calc && (a >= 0)      ? y + (x >> i) 
                : Calc && (a < 0)       ? y - (x >> i)
                : Place && (q == 0)     ? ykc 
                : Place && (q == 1)     ? xkc 
                : Place && (q == 2)     ? -ykc 
                : Place && (q == 3)     ? -xkc 
                : y;
               
    // datapath and FSM state update

    UPD(i,LINE); 
    UPD(q);
    UPD(x);
    UPD(y);
    UPD(xkc);
    UPD(ykc);
    UPD(a);   

    UPD(Get);
    UPD(Norm); 
    UPD(Calc);
    UPD(Mkc); 
    UPD(Place); 
    UPD(Put); 

    assert ((Get + Norm + Calc + Mkc + Place + Put) > 0); // FSM complet
    assert ((Get + Norm + Calc + Mkc + Place + Put) < 2); // FSM orthogonal
}

// description procédurale des stimuli
main()
{
    int c=0;
    char *PATNAME = getenv("PATNAME");
    char *DECSIG = getenv("SIGNAL");
    
    if (!PATNAME)
        PATNAME = "default";

    // le nom du fichier produit
    DEF_GENPAT(PATNAME);       
    SETTUNIT("ns");

    // interface 
    DECLAR("vdd",       ":2", "B",  IN, "", "");
    DECLAR("vss",       ":2", "B",  IN, "", "");
    DECLAR("ck",        ":2", "B",  IN, "", "");
    DECLAR("raz",       ":2", "B",  IN, "", "");

    DECLAR("wr_axy_p",  ":2", "B",  IN, "", "");
    DECLAR("a_p",       ":2", "X",  IN, "7 DOWNTO 0", "");
    DECLAR("x_p",       ":2", "X",  IN, "7 DOWNTO 0", "");
    DECLAR("y_p",       ":2", "X",  IN, "7 DOWNTO 0", "");
    DECLAR("wok_axy_p", ":2" ,"B",  OUT,"", "");

    DECLAR("rd_nxy_p",  ":2", "B",  IN, "", "");
    DECLAR("nx_p",      ":2", "X",  OUT, "7 DOWNTO 0", "");
    DECLAR("ny_p",      ":2", "X",  OUT, "7 DOWNTO 0", "");
    DECLAR("rok_nxy_p", ":2", "B",  OUT, "", "");

    if (DECSIG) {
        char signame[64];
#       define SIGNAME(name) sprintf(signame, "%s.%s", PATNAME, name);
        SIGNAME("get");     DECLAR(signame, ":2", "B",  REGISTER, "", "");
        SIGNAME("norm");    DECLAR(signame, ":2", "B",  REGISTER, "", "");
        SIGNAME("calc");    DECLAR(signame, ":2", "B",  REGISTER, "", "");
        SIGNAME("mkc");     DECLAR(signame, ":2", "B",  REGISTER, "", "");
        SIGNAME("place");   DECLAR(signame, ":2", "B",  REGISTER, "", "");
        SIGNAME("put");     DECLAR(signame, ":2", "B",  REGISTER, "", "");
        SIGNAME("i");       DECLAR(signame, ":2", "X",  REGISTER, "2 downto 0", "");
        SIGNAME("quadrant");DECLAR(signame, ":2", "X",  REGISTER, "1 downto 0", "");
        SIGNAME("x");       DECLAR(signame, ":2", "X",  REGISTER, "15 downto 0", "");
        SIGNAME("y");       DECLAR(signame, ":2", "X",  REGISTER, "15 downto 0", "");
        SIGNAME("a");       DECLAR(signame, ":2", "X",  REGISTER, "15 downto 0", "");
        SIGNAME("a_lt_0");  DECLAR(signame, ":2", "B",  SIGNAL, "", "");
        SIGNAME("quadrant_0");DECLAR(signame, ":2", "B",  SIGNAL, "", "");
        SIGNAME("atan");    DECLAR(signame, ":2", "X",  SIGNAL, "15 downto 0", "");
    }

    // valeurs initiales et raz
    AFFECT(cycle(0), "vdd",         "0b1");
    AFFECT(cycle(0), "vss",         "0b0");
    AFFECT(cycle(0), "raz",         "0b0");
    AFFECT(cycle(0), "wr_axy_p",    "0b0");
    AFFECT(cycle(0), "a_p",         "0b00000000");
    AFFECT(cycle(0), "x_p",         "0b00000000");
    AFFECT(cycle(0), "y_p",         "0b00000000");
    AFFECT(cycle(0), "rd_nxy_p",    "0b0");
    AFFECT(cycle(1), "raz",         "0b1");

    int nb_cycle = 0;
    int cmax = 2;
    short F_PI = (short)((M_PI) * (1<<7));
    short a;

    fprintf(stderr, "pi 0x%04x a_mpidiv2 0x%04x\n", F_PI, F_PI/2);
    for (a = 0; a <= 2*F_PI  ; a += 4) {

        char wr_axy_p = 1;
        short a_p = a;
        char x_p = 127;
        char y_p = 0;
        char wok_axy_p;  

        char rd_nxy_p = 1;
        char nx_p;
        char ny_p;
        char rok_nxy_p;

        AFFECT(cycle(cmax), "wr_axy_p",     "0b1");
        AFFECT(cycle(cmax), "a_p",          inttostrX(a>>2,8));
        AFFECT(cycle(cmax), "x_p",          inttostrX(127,8));
        AFFECT(cycle(cmax), "y_p",          inttostrX(0,8));
        AFFECT(cycle(cmax), "rd_nxy_p",     "0b1");

        LABEL("NEW");
        fprintf(stderr, "Pattern %d : angle %f %s\n", cmax*2, 180*((float)((a>>2)<<2)/F_PI), inttostrX(((a>>2)<<2),10));

        do {
            nb_cycle++;
            cordic_seq( 
            wr_axy_p,   a_p>>2,    x_p,    y_p,    &wok_axy_p, 
            rd_nxy_p,   &nx_p,  &ny_p,  &rok_nxy_p);
            AFFECT(out_cycle(cmax), "rok_nxy_p", inttostr(rok_nxy_p));
            AFFECT(out_cycle(cmax), "nx_p", inttostrX(nx_p,8));
            AFFECT(out_cycle(cmax), "ny_p", inttostrX(ny_p,8));
            cmax++;
        }
        while(rok_nxy_p == 0);
    }

    printf("Number of cycles : %d\n",nb_cycle);
    // la génération du signal d'horloge
    for (c = 0; c <= nb_cycle; c++) {
       AFFECT(cycle(c),         "ck", inttostr(0));
       AFFECT(next_cycle(c),    "ck", inttostr(1));
    }

    SAV_GENPAT();
    return 0;
}
