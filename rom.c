#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#ifndef ADDRWDMAX
#define ADDRWDMAX 16
#endif


#ifndef M_PI
#define M_PI 3.14159265358979323846 
#endif

void usage(char *message) {
    fprintf(stderr, "\nERROR : %s\n\n", message);
    fprintf(stderr, "USAGE rom <addrwd> <valwd>\n");
    fprintf(stderr, "  <addrwd>: number of bits of the rom address (max is %d)\n", ADDRWDMAX);
    fprintf(stderr, "  <valwd> : range of operands are between 1 to 2**valwd\n\n");
    fprintf(stderr, "Ex: rom 5 8 -> gives 10 triplets with operands from 1 to 2**8-1 (255)\n\n");
    exit(1);
}

unsigned value(unsigned valrange) {
    return 1 + (rand() % (valrange - 1));
}

unsigned twopow(unsigned n) {
    unsigned res = 1;
    while (n--) res *= 2;
    return res;
}

// CORDIC rotation using fixed-point math
short F_PI = (short)((M_PI) * (1 << 7)); // Approximate PI in fixed-point (7 fractional bits)
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

// CORDIC function to compute cosine and sine
void cordic(short a_p, char x_p, char y_p, char *nx_p, char *ny_p) {
    unsigned char i, q;
    short a, x, y, dx, dy;

    // Convert angle to fixed-point representation (7 fractional bits)
    a = a_p & 0b1111111100;
    x = x_p << 7;         
    y = y_p << 7;

    // Normalize the angle to the first quadrant
    q = 0;
    while (a >= F_PI / 2) {
        a = a - F_PI / 2; 
        q = (q + 1) & 3;
    }

    // Perform the CORDIC rotations
    for (i = 0; i <= 7; i++) {
        short dx = x >> i;
        short dy = y >> i;
        if (a >= 0) {
            x -= dy;
            y += dx;
            a -= ATAN[i];
        } else {
            x += dy;
            y -= dx;
            a += ATAN[i];
        }
    }

    // Scale the results
    x = ((x >> 6) + (x >> 5) + (x >> 4) + (x >> 1)) >> 7;
    y = ((y >> 6) + (y >> 5) + (y >> 4) + (y >> 1)) >> 7;

    // Clamp the values to be within the range of char (-128 to 127)
    x = (x > 127) ? 127 : (x < -128) ? -128 : x;
    y = (y > 127) ? 127 : (y < -128) ? -128 : y;

    // Adjust the final result to the correct quadrant
    switch (q) {
    case 0:
        dx = x;
        dy = y;
        break;
    case 1:
        dx = -y;
        dy = x;
        break;
    case 2:
        dx = -x;
        dy = -y;
        break;
    case 3:// Clamp the values to be within the range of char (-128 to 127)
    x = (x > 127) ? 127 : (x < -128) ? -128 : x;
    y = (y > 127) ? 127 : (y < -128) ? -128 : y;

        dx = y;
        dy = -x;
        break;
    }
    *nx_p = dx;
    *ny_p = dy;
}


int main(int argc, char *argv[]) {

    if (argc < 3) usage("Too few arguments");
    if (argc > 3) usage("Too many arguments");

    unsigned addrwd = atoi(argv[1]);
    unsigned valwd = atoi(argv[2]);
    if (addrwd > ADDRWDMAX) usage("<addrwd> too big (change ADDRWDMAX in source code)");

    unsigned valrange = twopow(valwd) - 1;
    unsigned valuenb = twopow(addrwd) / 5;

    char *name = "value";
    unsigned namelen = strlen(name);
    unsigned rangelen = 1 + (valwd - 1) / 4;

    for (int i = 0; i < valuenb; i++) {
        unsigned X = 127;
        unsigned Y = 0;
        unsigned A = value(valrange);  // Angle for rotation

        char cos_out, sin_out;
        cordic(A, X, Y, &cos_out, &sin_out);  // Use the cordic function

        if (i == 0)
            printf("%*s <= x\"%0*x\" when pt = %d\n", namelen, name, rangelen, X, i);
        else
            printf("%*s x\"%0*x\" when pt = %d\n", namelen + 3, "else", rangelen, X, 5 * i);
            printf("%*s x\"%0*x\" when pt = %d\n", namelen + 3, "else", rangelen, Y, 5 * i + 1);
            printf("%*s x\"%0*x\" when pt = %d\n", namelen + 3, "else", rangelen, A, 5 * i + 2);
            printf("%*s x\"%0*x\" when pt = %d\n", namelen + 3, "else", rangelen, cos_out, 5 * i + 3);
            printf("%*s x\"%0*x\" when pt = %d\n", namelen + 3, "else", rangelen, sin_out, 5 * i + 4);
    }

    printf("%*s x\"%0*x\";\n", namelen + 3, "else", rangelen, 0);

    fprintf(stderr, "rom generated with %d Quintuple (X, Y, a, cos, sin)\n", valuenb);
    return 0;
}
