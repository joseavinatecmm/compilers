#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

 // expresiones válidas "3", "+7", "-0", ".5", "12.", "12.34", "1e3", "-2.5E-8", ".7e+10", "12.e3"

typedef enum {
    S1=1, S2, S3, S4, S5, S6, S7, S8, S9
} State;

static int es_valida(const char *s) {
    State st = S1;
    for (size_t i = 0;; ++i) {
        unsigned char uc = (unsigned char)s[i];
        if (uc == '\0') {
            if (st == S3 || st == S5 || st == S8) {
                st = S9;
                return 1; /* válido */
            }
            return 0;     /* inválido */
        }

        switch (st) {
            case S1: 
                if (uc == '+' || uc == '-') {
                    st = S2;
                } else if (isdigit(uc)) {
                    st = S3;
                } else if (uc == '.') {
                    st = S4;
                } else {
                    return 0;
                }
                break;

            case S2: 
                if (isdigit(uc)) {
                    st = S3;
                } else if (uc == '.') {
                    st = S4;
                } else {
                    return 0;
                }
                break;

            case S3: 
                if (isdigit(uc)) {
                    // no transición
                } else if (uc == '.') {
                    st = S5;
                } else if (uc == 'e' || uc == 'E') {
                    st = S6;
                } else {
                    return 0;
                }
                break;

            case S4:
                if (isdigit(uc)) {
                    st = S5; 
                } else {
                    return 0; 
                }
                break;

            case S5: 
                if (isdigit(uc)) {
                    // no transición
                } else if (uc == 'e' || uc == 'E') {
                    st = S6;
                } else {
                    return 0;
                }
                break;

            case S6: 
                if (uc == '+' || uc == '-') {
                    st = S7;
                } else if (isdigit(uc)) {
                    st = S8;
                } else {
                    return 0;
                }
                break;

            case S7: 
                if (isdigit(uc)) {
                    st = S8;
                } else {
                    return 0;
                }
                break;

            case S8: 
                if (isdigit(uc)) {
                    // no transición
                } else {
                    return 0;
                }
                break;

            case S9: 
                return 0;
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "uso: %s <cadena>\n", argv[0]);
        return EXIT_FAILURE;
    }
    if (es_valida(argv[1])) {
        printf("La cadena \"%s\" es VÁLIDA en notación científica.\n", argv[1]);
        return EXIT_SUCCESS;
    } else {
        printf("La cadena \"%s\" NO es válida en notación científica.\n", argv[1]);
        return EXIT_FAILURE;
    }
}

