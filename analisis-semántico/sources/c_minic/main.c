#include <stdio.h>
#include "symtable.h"

int yyparse(void);
int yylex_destroy(void);

int main(void) {
    symtab_init();
    int rc = yyparse();
    if (rc == 0) puts("Análisis completado sin errores sintácticos.");
    else         puts("El análisis se interrumpió por errores.");
    symtab_free();
    yylex_destroy();
    return rc;
}

