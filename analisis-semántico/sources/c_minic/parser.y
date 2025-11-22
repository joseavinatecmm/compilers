%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"  

int yylex(void);
int yyparse(void);
int yycolumn(void);
extern int yylineno;

static void yyerror(const char *msg);
static int promote(int a, int b) { return (a==TYPE_FLOAT || b==TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT; }
%}

%union {
    int   ival;   
    float fval;   
    char* sval;  
}

%token T_INT T_FLOAT
%token <ival> ICONST
%token <fval> FCONST
%token <sval> ID

%left '+'
%left '*'

%type <ival> type_spec expr

%%

program
    : decl_or_stmt_list
    ;

decl_or_stmt_list
    : decl_or_stmt_list decl_or_stmt
    | /* vacío */
    ;

decl_or_stmt
    : decl ';'
    | assign ';'
    ;

decl
    : type_spec ID
      {
        if (!symtab_insert($2, $1)) {
            fprintf(stderr,"[%d:%d] Error: redeclaración de '%s'.\n", yylineno, yycolumn(), $2);
        }
        free($2);
      }
    ;

type_spec
    : T_INT   { $$ = TYPE_INT; }
    | T_FLOAT { $$ = TYPE_FLOAT; }
    ;

assign
    : ID '=' expr
      {
        Symbol *s = symtab_lookup($1);
        if (!s) {
            fprintf(stderr,"[%d:%d] Error: '%s' no declarada.\n", yylineno, yycolumn(), $1);
        } else if (s->type == TYPE_INT && $3 == TYPE_FLOAT) {
            fprintf(stderr,"[%d:%d] Advertencia: float → int puede truncar.\n", yylineno, yycolumn());
        }
        free($1);
      }
    ;

expr
    : expr '+' expr { $$ = promote($1, $3); }
    | expr '*' expr { $$ = promote($1, $3); }
    | '(' expr ')'  { $$ = $2; }
    | ID
      {
        Symbol *s = symtab_lookup($1);
        if (!s) {
            fprintf(stderr,"[%d:%d] Error: '%s' no declarada.\n", yylineno, yycolumn(), $1);
            $$ = TYPE_INT; 
        } else {
            $$ = s->type;  
        }
        free($1);
      }
    | ICONST { $$ = TYPE_INT; }
    | FCONST { $$ = TYPE_FLOAT; }
    ;

%%

static void yyerror(const char *msg) {
    fprintf(stderr, "[%d:%d] Error sintáctico: %s\n", yylineno, yycolumn(), msg);
}
