# Análisis Semántico: validación de scope

# 🎯 Manejo de Scope

+ Un *scope* o **ámbito** define la región del programa donde:

    - Las variables existen.
    - Los nombres son válidos.
    - Un identificador puede ocultar a otro del mismo nombre.
    - Las funciones tienen su propio ámbito.
    - Los bloques `{ ... }` crean sub-ámbitos.
    - No se puede usar una variable fuera de su ámbito.
    - Las variables locales viven sólo dentro del bloque.

+ Esto se implementa en el parser con una **pila de tablas de símbolos**.

---

# 🧠 1. ¿Qué es una “pila de scopes”?

Dado el siguiente programa:

```c
int x;

int f(int a) {
    int x;
    {
        int y;
        ...
    }
}
```

donde se cuenta con **tres scopes**:

1. Scope global  
2. Scope de la función `f`  
3. Scope del bloque `{ ... }` dentro de `f`

+ La finalidad del parser es darle seguimiento correcto a cada uno.

---

# 🧱 2. Definición de estructuras para manejar scopes

## ✔ Estructura de un símbolo

```c
typedef struct Simbolo {
    char *nombre;
    int  valor;
    int  inicializada;
    int  es_funcion;
    int  num_parametros;
    struct Simbolo *sig;
} Simbolo;
```

---

## ✔ Estructura de un scope (tabla)

```c
typedef struct Tabla {
    Simbolo *simbolos;
    struct Tabla *sig;
} Tabla;
```

Así se forma una pila como:

```
[Scope actual] → [Scope anterior] → [Scope global] → NULL
```

---

# 🚀 3. Crear un nuevo Scope

```c
void push_scope() {
    Tabla *nuevo = malloc(sizeof(Tabla));
    nuevo->simbolos = NULL;
    nuevo->sig = pila;
    pila = nuevo;
}
```

---

# 🧹 4. Abandonar un Scope

```c
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
```

---

# 🔍 5. Buscar una variable (respetando scope)

```c
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
```

---

# ➕ 6. Insertar una variable en el scope actual

```c
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
```

---

# 🧩 7. Uso de scopes en la gramática Bison

## ✔ Scope global

```c
int main() {
    push_scope(); // Crea ámbito global
    yyparse();
}
```

## ✔ Scope de función

```bison
declaracion_funcion:
      INT_T ID LPAREN parametros RPAREN bloque
        {
            pop_scope();
            Simbolo *f = insertar($2);
            f->es_funcion = 1;
            f->num_parametros = $4;
        }
```

## ✔ Scope de bloque

```bison
bloque:
      LBRACE { push_scope(); }
      lista_sentencias
      RBRACE { pop_scope(); }
    ;
```

---

# 🎉 RESUMEN

| Concepto | Explicación |
|----------|-------------|
| Crear ámbito | `push_scope()` |
| Salir de ámbito | `pop_scope()` |
| Búsqueda de variables | Respeta los scopes |
| Declaración | Sólo en el scope actual |
| Ocultamiento | Ámbitos internos sobre externos |
| Funciones | Generan scopes propios |
| Bloques `{}` | Cada uno crea un scope |

---

# 📌 Conclusión

Con una pila de scopes el lenguaje X puede:

- Tener variables locales reales  
- Aceptar funciones con parámetros  
- Usar scopes anidados  
- Ocultar nombres  
- Aplicar semántica correcta  

La técnica es exactamente la que usan lenguajes como C, Python, Java o Rust.

