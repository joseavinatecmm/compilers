#ifndef SYMTABLE_H
#define SYMTABLE_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TYPE_INT = 1,
    TYPE_CHAR = 2,
    TYPE_FLOAT = 3 
} Type;

typedef struct Symbol {
    char *name;
    Type type;
    struct Symbol *next;
} Symbol;

void     symtab_init(void);
void     symtab_free(void);
int      symtab_insert(const char *name, Type type); 
Symbol*  symtab_lookup(const char *name);
const char* type_to_string(Type t);

#ifdef __cplusplus
}
#endif
#endif

