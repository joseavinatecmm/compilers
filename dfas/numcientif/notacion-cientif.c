#include "sci_automata.h"
#include <ctype.h>

void sci_dfa_init(SciDFA *dfa) {
    dfa->state = S1;
    dfa->error = 0;
}

static int is_accepting_state(SciState st) {
    return (st == S3) || (st == S5) || (st == S8);
}

int sci_dfa_step(SciDFA *dfa, int ch) {
    if (dfa->error) return dfa->error; 

    unsigned char uc = (unsigned char)ch;
    SciState st = dfa->state;

    switch (st) {
        case S1: 
            if (uc == '+' || uc == '-') {
                dfa->state = S2;
            } else if (isdigit(uc)) {
                dfa->state = S3;
            } else if (uc == '.') {
                dfa->state = S4;
            } else {
                dfa->error = 1;
            }
            break;

        case S2: 
            if (isdigit(uc)) {
                dfa->state = S3;
            } else if (uc == '.') {
                dfa->state = S4;
            } else {
                dfa->error = 1;
            }
            break;

        case S3: 
            if (isdigit(uc)) {
            
            } else if (uc == '.') {
                dfa->state = S5;
            } else if (uc == 'e' || uc == 'E') {
                dfa->state = S6;
            } else {
                dfa->error = 1;
            }
            break;

        case S4: 
            if (isdigit(uc)) {
                dfa->state = S5;
            } else {
                dfa->error = 1; 
            }
            break;

        case S5: 
            if (isdigit(uc)) {
            } else if (uc == 'e' || uc == 'E') {
                dfa->state = S6;
            } else {
                dfa->error = 1;
            }
            break;

        case S6: 
            if (uc == '+' || uc == '-') {
                dfa->state = S7;
            } else if (isdigit(uc)) {
                dfa->state = S8;
            } else {
                dfa->error = 1;
            }
            break;

        case S7: 
            if (isdigit(uc)) {
                dfa->state = S8;
            } else {
                dfa->error = 1;
            }
            break;

        case S8: 
            if (isdigit(uc)) {
                // permanace
            } else {
                dfa->error = 1;
            }
            break;

        default:
            dfa->error = 1;
            break;
    }

    return dfa->error;
}

int sci_dfa_is_accepting(const SciDFA *dfa) {
    return !dfa->error && is_accepting_state(dfa->state);
}

int sci_validate_scientific(const char *s) {
    SciDFA dfa;
    sci_dfa_init(&dfa);

    for (size_t i = 0; s[i] != '\0'; ++i) {
        if (sci_dfa_step(&dfa, (unsigned char)s[i]) != 0) {
            return 0; // transición inválida
        }
    }

    return sci_dfa_is_accepting(&dfa);
}

