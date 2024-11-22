//--------------------------------------------------------------------------------------------------
// Generic Include File for genpat
//--------------------------------------------------------------------------------------------------

#ifndef _MYGENPAT_H_
#define _MYGENPAT_H_

#include <stdio.h>
#include <math.h>
#include <assert.h>
#include "genpat.h"
#include "alloca.h"
#include "stdarg.h"
#include "mut.h"

//--------------------------------------------------------------------------------------------------
// since it is not possible to get arguments with genpat, 
// we use environment variables. The GETENV() macro try to get
// the variable env value and we can choose a default value for each 
//--------------------------------------------------------------------------------------------------

#define GETENV(var,def) getenv(var)?getenv(var):def

//--------------------------------------------------------------------------------------------------
// Constantes générales
//--------------------------------------------------------------------------------------------------

const PERIOD = 2;

//--------------------------------------------------------------------------------------------------
// rend la date du cycle n°i ou du cycle n°i + 1 demi-cycle 
//--------------------------------------------------------------------------------------------------

#define cycle(i)        itoa(i*PERIOD)
#define next_cycle(i)   itoa(i*PERIOD + PERIOD/2)

//--------------------------------------------------------------------------------------------------
// Fabriquer une chaine de caractères à partir d'un entier
//
// namealloc fait l'équivalent de strdup() mais en plus il teste que la chaine 
//           en paramètre n'a pas déjà été allouée, si oui, namealloc rend
//           le pointeur sur la chaine déjà allouée, cette opération utilise
//           un dictionnaire (table de hachage)
//
// itoa(42)                 rend un pointeur sur "42"
// itoa(42)                 rend LE MÊME pointeur sur "42"
// itoa(0x42,4)             rend "0x0042"
// itoaX(0x42,1)            rend "0x2"
// itoaX(0x42,8)            rend "0x00000042"
// vector(A,B)              rend "A downto B" or "A to B" selon la valeur de A et de B
// toa("%s%d","test",3)     rend "test3"
//--------------------------------------------------------------------------------------------------

static inline char *itoa (int entier)
{
    char *str = (char *) alloca (32 * sizeof (char));   // allocation dans la pile

    sprintf (str, "%d", entier);
    return namealloc (str);     // utilise un dictionnaire
}

static inline char *itoaX (int entier, int size)
{
    int mask;

    for (mask = 0; size; mask = (mask << 1) | 1, size--);
    char *str = (char *) alloca (32 * sizeof (char));   // allocation dans la pile

    sprintf (str, "0x%0*x", size, entier & mask);
    return namealloc (str);     // utilise un dictionnaire
}

static inline char *vector (int from, int to)
{
    char *str = (char *) alloca (32 * sizeof (char));   // allocation dans la pile
    if (from > to)
        sprintf (str, "%d downto %d", from, to);
    else
        sprintf (str, "%d to %d", from, to);
    return namealloc (str);     // utilise un dictionnaire
}

static inline char *toa (char *fmt, ...)
{
    char str[256];
    va_list ap;
    va_start (ap, fmt);
    vsnprintf (str, sizeof(str), fmt, ap);
    va_end (ap);
    return namealloc (str);     // utilise un dictionnaire
}

#endif //_MYGENPAT_H_ 
