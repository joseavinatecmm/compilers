#include <stdio.h>
#include <stdlib.h>
#include <ctype.h> 

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <cadena>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *cadena = argv[1];
    int i = 0;
    int esAlfabetica = 1;

    while (cadena[i] != '\0') {
        char c = cadena[i];

        switch (isalpha((unsigned char)c)) {
            case 0: // No es alfabético
                esAlfabetica = 0;
                break;
            default:
                // es alfabética, no hacemos nada especial
                break;
        }

        if (!esAlfabetica) break;
        i++;
    }

    if (esAlfabetica) {
        printf("La cadena \"%s\" es válida \n", cadena);
    } else {
        printf("La cadena \"%s\" contiene caracteres NO alfabéticos.\n", cadena);
    }

    return EXIT_SUCCESS;
}

