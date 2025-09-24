#include <stdio.h>
#include <stdlib.h>
#include "sci_automata.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "uso: %s <cadena>\n", argv[0]);
        return EXIT_FAILURE;
    }

    if (sci_validate_scientific(argv[1])) {
        printf("La cadena \"%s\" es válida ... en notación científica.\n", argv[1]);
        return EXIT_SUCCESS;
    } else {
        printf("La cadena \"%s\" no es válida ... en notación científica.\n", argv[1]);
        return EXIT_FAILURE;
    }
}

