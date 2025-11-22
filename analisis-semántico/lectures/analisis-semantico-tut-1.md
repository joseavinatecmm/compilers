
# 🧩 Análisis Sintáctico: Tabla de Símbolos

## 🔹 1. ¿Qué es el análisis sintáctico?

+ El **análisis sintáctico** (parser) es la etapa del compilador encargada de verificar que las estructuras del programa fuente **siguen las reglas gramaticales** del lenguaje.  

+ En esta etapa se utiliza una **gramática libre de contexto (GLC)** para definir cómo se pueden combinar los tokens (provenientes del análisis léxico) y formar **estructuras válidas**, como declaraciones, expresiones o asignaciones.

Ejemplo de producciones en C simplificado:

```bison
program     → decl_or_stmt_list
decl_or_stmt_list → decl_or_stmt_list decl_or_stmt | ε
decl_or_stmt → decl ';' | assign ';'
decl        → type_spec ID
assign      → ID '=' expr
expr        → expr '+' expr | expr '*' expr | ID | ICONST | FCONST
type_spec   → 'int' | 'float'
```

---

## 🔹 2. El rol de la tabla de símbolos

+ Una **tabla de símbolos** es una estructura de datos que el compilador utiliza para **registrar información** sobre los identificadores del programa, como variables, constantes o funciones.

+ Durante el análisis sintáctico, el compilador:
1. **Inserta** en la tabla cada identificador cuando se declara.
2. **Consulta** la tabla cada vez que se usa una variable o constante.
3. **Verifica compatibilidad de tipos** (por ejemplo, `float` vs `int`).
4. **Reporta errores semánticos** cuando algo no está declarado o se redeclara.

---

## 🔹 3. Integración de la tabla de símbolos en `parser.y`

En el archivo **`parser.y`** se incluye la cabecera `symtable.h`:

```c
%{
#include "symtable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylineno;
int yycolumn(void);
static void yyerror(const char *msg);
%}
```

Esto permite usar funciones como:
- `symtab_insert(nombre, tipo)` → agrega una nueva variable.
- `symtab_lookup(nombre)` → busca si la variable fue declarada.
- `symtab_free()` → limpia la tabla al finalizar.

---

## 🔹 4. ¿Qué es el `%union` y por qué se usa?

+ Bison debe manejar distintos tipos de valores: enteros, flotantes, cadenas o tipos de datos.  

+ Por eso, se define una **unión de C** que contiene todos los posibles tipos de valor que los tokens o no terminales pueden tener:

```bison
%union {
    int   ival;   /* Constantes enteras */
    float fval;   /* Constantes flotantes */
    char* sval;   /* Identificadores */
    Type  type;   /* Tipos de datos (int, float) */
}
```

Luego se indica qué campo de esta unión usará cada símbolo:

```bison
%token <ival> ICONST
%token <fval> FCONST
%token <sval> ID
%type  <type> expr type_spec
```

Esto le dice al parser **qué tipo de valor tiene cada símbolo**.

---

## 🔹 5.`$1`, `$2`, `$3` y `$$`

+ En cada regla de producción, los símbolos `$1`, `$2`, `$3`, ... se refieren a los **valores semánticos de los elementos del lado derecho**.  

+ El símbolo **$$** representa **el valor semántico del no terminal del lado izquierdo**.

Ejemplo:

```bison
expr : expr '+' expr { $$ = promote($1, $3); }
```

Aquí:
- `$1` es el tipo de la subexpresión izquierda.
- `$3` es el tipo de la subexpresión derecha.
- `$$` será el tipo resultante después de aplicar la promoción de tipos.

---

## 🔹 6. Inserción en la tabla de símbolos (declaraciones)

Cuando el parser reconoce una **declaración**, inserta la variable en la tabla de símbolos:

```bison
decl
    : type_spec ID
      {
        if (!symtab_insert($2, $1)) {
            fprintf(stderr, "[%d] Error: variable redeclarada '%s'.\n", yylineno, $2);
        }
        free($2);
      }
    ;
```

Explicación paso a paso:
1. `$1` → contiene el tipo (`TYPE_INT` o `TYPE_FLOAT`).
2. `$2` → contiene el nombre del identificador (`"x"`, `"y"`, etc.).
3. `symtab_insert($2, $1)` guarda esa información en la tabla.
4. Si el nombre ya existía, se genera un **error de redeclaración**.
5. Finalmente, se libera la memoria de `$2`.

---

## 🔹 7. Verificación de asignaciones

Cuando se analiza una **asignación**, el parser comprueba si la variable está declarada:

```bison
assign
    : ID '=' expr
      {
        Symbol *s = symtab_lookup($1);
        if (!s) {
            fprintf(stderr, "[%d] Error: variable no declarada '%s'.\n", yylineno, $1);
        } else {
            if (s->type == TYPE_INT && $3 == TYPE_FLOAT) {
                fprintf(stderr, "[%d] Advertencia: asignación de float a int.\n", yylineno);
            }
        }
        free($1);
      }
    ;
```

Interpretación de los símbolos:
| Símbolo | Significado | Valor |
|----------|-------------|--------|
| `$1` | Identificador (ID) | `"x"` |
| `$2` | Operador `'='` | No tiene valor |
| `$3` | Expresión (expr) | Tipo resultante (`TYPE_INT` o `TYPE_FLOAT`) |
| `$$` | Resultado de la regla (opcional) | Tipo del resultado o éxito de la operación |

---

## 🔹 8. Evaluación de expresiones

Las expresiones también propagan tipos usando `$` y `$$`:

```bison
expr
    : expr '+' expr  { $$ = promote($1, $3); }
    | expr '*' expr  { $$ = promote($1, $3); }
    | ICONST         { $$ = TYPE_INT; }
    | FCONST         { $$ = TYPE_FLOAT; }
    | ID
      {
        Symbol *s = symtab_lookup($1);
        if (!s) {
            fprintf(stderr, "[%d] Error: variable '%s' no declarada.\n", yylineno, $1);
            $$ = TYPE_INT; /* Recuperación */
        } else {
            $$ = s->type;
        }
        free($1);
      }
    ;
```

Así, si la expresión es `x + 2.5`, y `x` es entero (`TYPE_INT`), la función `promote()` determinará que el resultado es `TYPE_FLOAT`.

---

## 🔹 9. Inserción del código para manejar la tabla de producciones

+ La tabla de símbolos se usa **dentro de las acciones semánticas** (las llaves `{ ... }` después de cada regla).  

+ Ahí es donde se **inserta o consulta** información dependiendo de la producción.

+ Por ejemplo, la producción de declaración y asignación manejan la tabla así:

```bison
decl    : type_spec ID    { symtab_insert($2, $1); }
assign  : ID '=' expr     { symtab_lookup($1); }
expr    : expr '+' expr   { $$ = promote($1, $3); }
```

Cada una de estas acciones se ejecuta **cuando la regla se reduce**, lo que significa que el parser ha reconocido esa estructura completa.

---

## 🔹 10. Relación entre las producciones y la tabla de símbolos

| Producción | Acción semántica | Operación sobre la tabla |
|-------------|------------------|---------------------------|
| `type_spec ID` | Se inserta el identificador y su tipo | `symtab_insert()` |
| `ID '=' expr` | Se busca el identificador | `symtab_lookup()` |
| `expr '+' expr` | Se evalúan los tipos | `promote()` |
| `FCONST`, `ICONST` | Devuelven tipo básico | `$$ = TYPE_FLOAT` o `TYPE_INT` |

De este modo, el **análisis sintáctico y el semántico trabajan juntos**:  
Bison reconoce las estructuras gramaticales y, al mismo tiempo, ejecuta código C para validar su coherencia semántica.

---

## 🔹 11. Resumen

El uso de `$1`, `$2`, `$3` y `$$` en las acciones semánticas permite conectar la **forma (sintaxis)** con el **significado (semántica)**.  
La tabla de símbolos es el puente que conserva la información de cada identificador y permite:

1. Detectar variables no declaradas.  
2. Evitar redeclaraciones.  
3. Controlar los tipos de datos.  
4. Mantener la coherencia entre las expresiones.

