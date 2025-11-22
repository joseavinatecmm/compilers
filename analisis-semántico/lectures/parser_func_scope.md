# Parser and scopes para 

+ En este parser se valida:

    - Declaración de variables
    - Declaración de funciones
    - Manejo de scopes (ámbitos) anidados
    - Validación semántica (redeclaración, no declarada, no inicializada, división entre cero)
    - Validación de parámetros de funciones
    - Evaluación de expresiones aritméticas
    - Instrucción `print`
    - Instrucción `return`
    - Ámbitos por función y por bloque

---

## Ejemplo de input.c

```c

int g1;
int g2;

int suma(int a, int b) {
    int x;
    x = a + b;
    return x;
}

int otra(int v) {
    int temp;
    temp = v * 2;

    {   /* bloque anidado */
        int x;
        x = temp + 5;
        print(x);   /* imprime el valor dentro del bloque anidado */
    }

    return temp;
}

int main() {
    int r;
    int y;

    g1 = 3;
    g2 = 4;

    r = suma(g1, g2);
    print(r);

    y = otra(r);
    print(y);

    {
        int z;
        z = y + r;
        print(z);
    }

    return 0;
}
```

---
## 📌 Archivo `parser.y` completo

```bison
/* parser.y — Analizador sintáctico y semántico con funciones y scope */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ======================= TABLAS DE SÍMBOLOS ======================= */

typedef struct Simbolo {
    char *nombre;
    int  valor;
    int  inicializada;
    int  es_funcion;
    int  num_parametros;
    struct Simbolo *sig;
} Simbolo;

/* Pila de ámbitos (scopes) */
typedef struct Tabla {
    Simbolo *simbolos;
    struct Tabla *sig;
} Tabla;

Tabla *pila = NULL;

/* Crear un scope nuevo */
void push_scope() {
    Tabla *nuevo = (Tabla*)malloc(sizeof(Tabla));
    nuevo->simbolos = NULL;
    nuevo->sig = pila;
    pila = nuevo;
}

/* Eliminar scope */
void pop_scope() {
    if (!pila) return;
    Tabla *tmp = pila;
    pila = pila->sig;
    Simbolo *s = tmp->simbolos;
    while (s) {
        Simbolo *next = s->sig;
        free(s->nombre);
        free(s);
        s = next;
    }
    free(tmp);
}

/* Buscar símbolo respetando scope */
Simbolo *buscar(const char *nombre) {
    Tabla *t = pila;
    while (t) {
        Simbolo *s = t->simbolos;
        while (s) {
            if (strcmp(s->nombre, nombre) == 0)
                return s;
            s = s->sig;
        }
        t = t->sig;
    }
    return NULL;
}

/* Insertar símbolo en el scope actual */
Simbolo *insertar(const char *nombre) {
    if (!pila) push_scope();
    if (buscar(nombre)) return NULL;

    Simbolo *s = malloc(sizeof(Simbolo));
    s->nombre = strdup(nombre);
    s->valor = 0;
    s->inicializada = 0;
    s->es_funcion = 0;
    s->num_parametros = 0;
    s->sig = pila->simbolos;
    pila->simbolos = s;
    return s;
}

int yylex(void);
void yyerror(const char *s);

%}

%union {
    int ival;
    char *sval;
}

%token INT_T
%token RETURN_T
%token PRINT_T

%token <sval> ID
%token <ival> NUM

%token ASSIGN SEMI COMMA
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN LBRACE RBRACE

%type <ival> expr term factor

%start programa

%%

programa:
      lista_declaraciones
    ;

lista_declaraciones:
      lista_declaraciones declaracion
    | /* vacío */
    ;

declaracion:
      declaracion_variable
    | declaracion_funcion
    ;

declaracion_variable:
      INT_T ID SEMI
        {
            if (!insertar($2))
                printf("Error: redeclaración de '%s'\n", $2);
        }
    ;

declaracion_funcion:
      INT_T ID LPAREN parametros RPAREN bloque
        {
            pop_scope();
            Simbolo *f = insertar($2);
            if (!f)
                printf("Error: redeclaración de función '%s'\n", $2);
            else {
                f->es_funcion = 1;
                f->num_parametros = $4;
            }
        }
    ;

parametros:
      /* vacío */ { $$ = 0; }
    | lista_parametros { $$ = $1; }
    ;

lista_parametros:
      INT_T ID
        {
            push_scope();
            Simbolo *p = insertar($2);
            if (!p) printf("Error: redeclaración de parámetro '%s'\n", $2);
            $$ = 1;
        }
    | lista_parametros COMMA INT_T ID
        {
            Simbolo *p = insertar($4);
            if (!p) printf("Error: redeclaración de parámetro '%s'\n", $4);
            $$ = $1 + 1;
        }
    ;

bloque:
      LBRACE lista_sentencias RBRACE
    ;

lista_sentencias:
      lista_sentencias sentencia
    | /* vacío */
    ;

sentencia:
      sentencia_variable
    | sentencia_asignacion
    | sentencia_print
    | sentencia_return
    | bloque
    ;

sentencia_variable:
      INT_T ID SEMI
        {
            if (!insertar($2))
                printf("Error: redeclaración de variable '%s'\n", $2);
        }
    ;

sentencia_asignacion:
      ID ASSIGN expr SEMI
        {
            Simbolo *s = buscar($1);
            if (!s)
                printf("Error: variable '%s' no declarada\n", $1);
            else {
                s->valor = $3;
                s->inicializada = 1;
            }
        }
    ;

sentencia_print:
      PRINT_T LPAREN expr RPAREN SEMI
        {
            printf("%d\n", $3);
        }
    ;

sentencia_return:
      RETURN_T expr SEMI
        { }
    ;

expr:
      expr PLUS term          { $$ = $1 + $3; }
    | expr MINUS term         { $$ = $1 - $3; }
    | term                    { $$ = $1; }
    ;

term:
      term TIMES factor       { $$ = $1 * $3; }
    | term DIV factor
        {
            if ($3 == 0) {
                printf("Error: división entre cero\n");
                $$ = 0;
            } else $$ = $1 / $3;
        }
    | factor                  { $$ = $1; }
    ;

factor:
      NUM                     { $$ = $1; }
    | ID
        {
            Simbolo *s = buscar($1);
            if (!s)
                printf("Error: variable '%s' no declarada\n", $1);
            else if (!s->inicializada)
                printf("Advertencia: variable '%s' no inicializada\n", $1);
            $$ = s ? s->valor : 0;
        }
    | LPAREN expr RPAREN      { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    printf("Error sintáctico: %s\n", s);
}

int main() {
    push_scope();
    printf("Analizando programa...\n");
    yyparse();
    return 0;
}
```


