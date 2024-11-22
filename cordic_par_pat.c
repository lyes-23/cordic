#include "mygenpat.h"

int main () {

    // Get Environment Variables As Arguments
    char* MODEL  = GETENV("MODEL","cordic_par");  // Default model name
    unsigned CYCLES = atoi(GETENV("CYCLES","100"));  // Default number of cycles
    char* TYPE   = GETENV("TYPE","BEH");  // Default to behavioral type
    
    // Define Filename based on Type
    if (strcmp(TYPE, "BEH") == 0)
        DEF_GENPAT(toa("%s_gen", MODEL));
    else
        DEF_GENPAT(toa("%s_genx", MODEL));

    // External Signals (mandatory)
    DECLAR("ck",       ":2", "B", IN,  "", "");
    DECLAR("nreset",   ":2", "B", IN,  "", "");
    DECLAR("a",        ":2", "B", IN,  "", "");
    DECLAR("x",        ":2", "B", IN,  "", "");
    DECLAR("y",        ":2", "B", IN,  "", "");
    DECLAR("wr_axy_p", ":2", "B", IN,  "", "");
    DECLAR("wok_axy_p", ":2", "B", OUT, "", "");
    DECLAR("a_p", ":2", "X", OUT, vector(7,0), "");
    DECLAR("x_p", ":2", "X", OUT, vector(7,0), "");
    DECLAR("y_p", ":2", "X", OUT, vector(7,0), "");

    // Initial Signal Values
    AFFECT(cycle(0), "nreset", "0");
    AFFECT(cycle(1), "nreset", "1");  // Release reset after the first cycle

    AFFECT(cycle(0), "vdd", "1");
    AFFECT(cycle(0), "vss", "0");

    // Clock Generator
    int c;
    for (c = 0; c <= CYCLES; c++) {
        AFFECT(cycle(c), "ck", itoa(0));  // Clock low
        AFFECT(next_cycle(c), "ck", itoa(1));  // Clock high
    }

    // Signal Transitions (simplified logic based on your original VHDL)
    int i = 0;
    int j = 0;
    for (c = 2; c <= CYCLES + 2; c++) {
        char wr_axy_p = (i != 7);  // Write when i is not 7
        char wok_axy_p = (i == 7) ? 1 : 0;

        // Set the values for a_p, x_p, and y_p based on i
        char a_p[8] = {0}, x_p[8] = {0}, y_p[8] = {0};
        if (i >= 0 && i <= 7) {
            a_p[i] = 1;  // Assign 'a' signal to the current bit in the vector
            x_p[i] = 1;  // Assign 'x' signal to the current bit in the vector
            y_p[i] = 1;  // Assign 'y' signal to the current bit in the vector
        }

        // Apply signal values to the pattern
        AFFECT(cycle(c), "wr_axy_p", itoa(wr_axy_p));
        AFFECT(cycle(c), "wok_axy_p", itoa(wok_axy_p));

        // Apply values for a_p, x_p, y_p
        for ( j = 0; j < 8; j++) {
            AFFECT(cycle(c), "a_p", itoa(a_p[j]));
            AFFECT(cycle(c), "x_p", itoa(x_p[j]));
            AFFECT(cycle(c), "y_p", itoa(y_p[j]));
        }

        // Update the counter for the next iteration
        if (wr_axy_p) {
            if (i < 7) {
                i++;  // Increment i until it reaches 7
            } else {
                i = 0;  // Reset i after reaching 7
            }
        }
    }

    // Save the generated patterns
    SAV_GENPAT();

    return 0;
}
