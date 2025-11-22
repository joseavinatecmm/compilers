#ifndef SYMTABLE_H
#define SYMTABLE_H

#define TYPE_INT   1
#define TYPE_FLOAT 2
typedef int Type; 

typedef struct Symbol {
    char *name;
    Type  type;        /* 1=int, 2=float */
    struct Symbol *next;
} Symbol;

void    symtab_init(void);
void    symtab_free(void);
int     symtab_insert(const char *name, Type type); /* 0 si ya existe, 1 si insertó */
Symbol* symtab_lookup(const char *name);
int     symtab_set_type(const char *name, Type type);
const char* type_to_string(Type t);

#endif

