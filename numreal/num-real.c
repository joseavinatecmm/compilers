#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>  

typedef enum {
    INICIO = 0,
    ENTEROS,
    PUNTO_SIN_ENTERO,
    PUNTO_TRAS_ENTERO,
    FRACCION,
    ERROR
} Estado;

static int es_estado_aceptacion(Estado st) {
    return (st == ENTEROS) || (st == FRACCION);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "uso: %s <numero_decimal>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *cadena = argv[1];

    // Cadena vacía: no válida
    if (cadena[0] == '\0') {
        printf("La cadena está vacía y no es un número decimal válido.\n");
        return EXIT_FAILURE;
    }

    Estado st = INICIO;

    for (size_t i = 0; cadena[i] != '\0'; ++i) {
        unsigned char c = (unsigned char)cadena[i];

        switch (st) {
            case INICIO:
                if (isdigit(c)) {
                    st = ENTEROS;
                } else if (c == '.') {
                    st = PUNTO_SIN_ENTERO;  
                } else {
                    st = ERROR;
                }
                break;

            case ENTEROS:
                if (isdigit(c)) {

                }
                else if (c == '.') {
                    st = PUNTO_TRAS_ENTERO;  
                } else {
                    st = ERROR;
                }
                break;

            case PUNTO_SIN_ENTERO:
                if (isdigit(c)) {
                    st = FRACCION;           
                } else {
                    st = ERROR;              
                }
                break;

            case PUNTO_TRAS_ENTERO:
                if (isdigit(c)) {
                    st = FRACCION;           
                } else {
                    st = ERROR;              
                }
                break;

            case FRACCION:
                if (isdigit(c)) {
                } else {
                    st = ERROR;              
                }
                break;

            case ERROR:
            default:
                break;
        }

        if (st == ERROR) break;
    }

    if (es_estado_aceptacion(st)) {
        printf("La cadena \"%s\" es válida.\n", cadena);
        return EXIT_SUCCESS;
    } else {
        printf("La cadena \"%s\" NO es un número decimal válido.\n", cadena);
        return EXIT_FAILURE;
    }
}

