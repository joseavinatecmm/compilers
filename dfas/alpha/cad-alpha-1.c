#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "uso: %s <cadena>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *cadena = argv[1];
    int i = 0;
    int esAlfabetica = 1;  

    while (cadena[i] != '\0') {
        char c = cadena[i];
        switch (c) {
            case 'A': case 'B': case 'C': case 'D': case 'E':
            case 'F': case 'G': case 'H': case 'I': case 'J':
            case 'K': case 'L': case 'M': case 'N': case 'O':
            case 'P': case 'Q': case 'R': case 'S': case 'T':
            case 'U': case 'V': case 'W': case 'X': case 'Y': case 'Z':
            // minúsculas
            case 'a': case 'b': case 'c': case 'd': case 'e':
            case 'f': case 'g': case 'h': case 'i': case 'j':
            case 'k': case 'l': case 'm': case 'n': case 'o':
            case 'p': case 'q': case 'r': case 's': case 't':
            case 'u': case 'v': case 'w': case 'x': case 'y': case 'z':
                break;
            default:
                esAlfabetica = 0;
                break;
        }

        if (!esAlfabetica) {
            break; 
        }
        i++;
    }

    if (esAlfabetica) {
        printf("La cadena \"%s\" es válida .\n", cadena);
    } else {
        printf("La cadena \"%s\" contiene caracteres NO alfabéticos.\n", cadena);
    }

    return EXIT_SUCCESS;
}

