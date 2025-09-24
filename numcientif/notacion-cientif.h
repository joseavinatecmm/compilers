#ifndef SCI_AUTOMATA_H
#define SCI_AUTOMATA_H

#include <stddef.h>

// Estados del DFA
typedef enum {
    S1 = 1, 
    S2,     
    S3,     
    S4,     
    S5,     
    S6,     
    S7,     
    S8     
} SciState;

// autómata: estado actual y bandera de error 
typedef struct {
    SciState state;
    int error; // 0 = ok, 1 = error de transición
} SciDFA;

// Inicializa el DFA en el estado de inicio
void sci_dfa_init(SciDFA *dfa);

// Procesa cada carácter y actualiza el estado.
//   Devuelve 0 si la transición es válida, !=0 si hubo error
int sci_dfa_step(SciDFA *dfa, int ch);

// Al concluir el análsis, el DFA indica si está en estado de aceptación
int sci_dfa_is_accepting(const SciDFA *dfa);

// Devuelve 1 si la cadena es válida, 0 de lo contrario
int sci_validate_scientific(const char *s);

#endif /* SCI_AUTOMATA_H */

