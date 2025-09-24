#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>   // isalpha

#define ES_ALFABETICO(ch) (isalpha((unsigned char)(ch)) ? 1 : 0)

typedef enum {
    INICIO,      
    ACEPTACION,  
    ERROR        
} Estado;

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "uso: %s <cadena>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *cadena = argv[1];
    Estado estado = INICIO;
    int i = 0;

    while (cadena[i] != '\0') {
        char c = cadena[i];

        switch (estado) {
            case INICIO:
            case ACEPTACION:
                if (ES_ALFABETICO(c)) {
                    estado = ACEPTACION;    
                } else {
                    estado = ERROR;         
                }
                break;

            case ERROR:
                break;
        }

        if (estado == ERROR) break;
        i++;
    }

    // Verificación final
    if (estado == INICIO || estado == ACEPTACION) {
        printf("La cadena \"%s\" es válida.\n", cadena);
    } else {
        printf("La cadena \"%s\" contiene caracteres no alfabéticos.\n", cadena);
    }

    return EXIT_SUCCESS;
}

