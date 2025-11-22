#include "symtable.h"
#include <stdlib.h>
#include <string.h>

static Symbol *symtab_head = NULL;

static char* my_strdup(const char *s) {
    if (!s) return NULL;
    size_t n = strlen(s) + 1;
    char *p = (char*)malloc(n);
    if (p) memcpy(p, s, n);
    return p;
}

void symtab_init(void) {
    symtab_head = NULL;
}

void symtab_free(void) {
    Symbol *cur = symtab_head;
    while (cur) {
        Symbol *n = cur->next;
        free(cur->name);
        free(cur);
        cur = n;
    }
    symtab_head = NULL;
}

Symbol* symtab_lookup(const char *name) {
    for (Symbol *s = symtab_head; s; s = s->next)
        if (strcmp(s->name, name) == 0) return s;
    return NULL;
}

int symtab_insert(const char *name, Type type) {
    if (symtab_lookup(name)) return 0;
    Symbol *s = (Symbol*)malloc(sizeof(Symbol));
    if (!s) return 0;
    s->name = my_strdup(name);
    s->type = type;
    s->next = symtab_head;
    symtab_head = s;
    return 1;
}

int symtab_set_type(const char *name, Type type) {
    Symbol *s = symtab_lookup(name);
    if (!s) return 0;
    s->type = type;
    return 1;
}

const char* type_to_string(Type t) {
    if (t == TYPE_INT)   return "int";
    if (t == TYPE_FLOAT) return "float";
    return "<?>";
}

