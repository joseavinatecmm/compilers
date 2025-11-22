%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"

int yylex(void);
void yyerror(const char *s);
int yycolumn(void);
extern int yylineno;

/* Promoción mínima de tipos (int/char -> int por simplicidad) */
static Type promote(Type a, Type b){
    if (a == TYPE_INT && b == TYPE_INT) return TYPE_INT;
    if (a == TYPE_CHAR && b == TYPE_CHAR) return TYPE_CHAR;
    if ((a == TYPE_INT && b == TYPE_CHAR) || (a == TYPE_CHAR && b == TYPE_INT)) return TYPE_INT;
    return TYPE_INT;
}
%}

/* ===== Unión de valores semánticos ===== */
%union {
    int   ival;
    char* sval;
    Type  type;
}

/* ===== Tokens ===== */
%token <sval> T_INCLUDE
%token T_INT T_CHAR T_RETURN
%token <ival> ICONST
%token <sval> STRING
%token <sval> ID

%left '+' '-'
%left '*' '/'

%type <type> type_spec expr

%%

translation_unit
    : includes global_items
    | includes
    | global_items
    ;

includes
    : includes include
    | include
    ;

include
    : T_INCLUDE { free($1); }
    ;

global_items
    : global_items global_item
    | global_item
    ;

global_item
    : decl ';'
    | func_def
    ;

decl
    : type_spec decl_list
    ;

decl_list
    : init_decl
    | decl_list ',' init_decl
    ;

init_decl
    : ID                       { if(!symtab_insert($1, TYPE_INT)){} free($1); }
    | ID '=' expr              { if(!symtab_insert($1, $3)){} free($1); }
    | '*' ID                   { if(!symtab_insert($2, TYPE_INT)){} free($2); }
    | '*' ID '=' expr          { if(!symtab_insert($2, $4)){} free($2); }
    ;

type_spec
    : T_INT    { $$ = TYPE_INT; }
    | T_CHAR   { $$ = TYPE_CHAR; }
    ;

func_def
    : type_spec ID '(' param_list_opt ')' compound_stmt
      {
        free($2);
      }
    ;

param_list_opt
    : /* empty */
    | param_list
    ;

param_list
    : param
    | param_list ',' param
    ;

param
    : type_spec ID             { if(!symtab_insert($2,$1)){} free($2); }
    | type_spec '*' ID         { if(!symtab_insert($3,$1)){} free($3); }
    | type_spec ID '[' ']'     { if(!symtab_insert($2,$1)){} free($2); }
    | type_spec '*' ID '[' ']' { if(!symtab_insert($3,$1)){} free($3); }
    ;

compound_stmt
    : '{' stmt_list_opt '}'
    ;

stmt_list_opt
    : /* empty */
    | stmt_list
    ;

stmt_list
    : stmt
    | stmt_list stmt
    ;

stmt
    : decl ';'
    | assign ';'
    | func_call ';'
    | return_stmt ';'
    ;

assign
    : ID '=' expr
      {
        Symbol *s = symtab_lookup($1);
        if(!s){
            fprintf(stderr,"[%d:%d] Error: variable no declarada '%s'\n", yylineno, yycolumn(), $1);
        }else{
            /* verificar compatibilidad */
        }
        free($1);
      }
    ;

func_call
    : ID '(' arg_list_opt ')'
      {
        free($1);
      }
    ;

arg_list_opt
    : /* empty */
    | arg_list
    ;

arg_list
    : expr
    | arg_list ',' expr
    ;

return_stmt
    : T_RETURN expr
    | T_RETURN ID { free($2); }
    ;

expr
    : ICONST        { $$ = TYPE_INT; }
    | STRING        { $$ = TYPE_INT; free($1); }
    | ID
      {
        Symbol *s = symtab_lookup($1);
        if(!s){
            fprintf(stderr,"[%d:%d] Error: uso de id no declarado '%s'\n", yylineno, yycolumn(), $1);
            $$ = TYPE_INT;
        }else{
            $$ = s->type;
        }
        free($1);
      }
    | expr '+' expr { $$ = promote($1,$3); }
    | expr '-' expr { $$ = promote($1,$3); }
    | expr '*' expr { $$ = promote($1,$3); }
    | expr '/' expr { $$ = promote($1,$3); }
    | '(' expr ')'  { $$ = $2; }
    ;

%%

void yyerror(const char *s){
    fprintf(stderr,"[%d:%d] Error sintáctico: %s\n", yylineno, yycolumn(), s);
}
