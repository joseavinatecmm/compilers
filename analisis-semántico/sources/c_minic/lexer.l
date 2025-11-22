%option noyywrap
%option yylineno
%option nounput noinput

%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

static int yycol = 1;
static void current_col(const char *yytext) {
    for (const char *p = yytext; *p; ++p) {
        if (*p == '\n') yycol = 1;
        else yycol++;
    }
}
%}

DIGIT      [0-9]
ID_START   [A-Za-z_]
ID_CONT    [A-Za-z0-9_]
INTCONST   {DIGIT}+
FCONST1    {DIGIT}+"."{DIGIT}*
FCONST2    {DIGIT}*"."{DIGIT}+

%%

"int"           { current_col(yytext); return T_INT; }
"float"         { current_col(yytext); return T_FLOAT; }

{FCONST1}       { current_col(yytext); yylval.fval = strtof(yytext, NULL); return FCONST; }
{FCONST2}       { current_col(yytext); yylval.fval = strtof(yytext, NULL); return FCONST; }
{INTCONST}      { current_col(yytext); yylval.ival = atoi(yytext); return ICONST; }

{ID_START}{ID_CONT}*  { current_col(yytext); yylval.sval = strdup(yytext); return ID; }

"=" { current_col(yytext); return '='; }
";" { current_col(yytext); return ';'; }
"(" { current_col(yytext); return '('; }
")" { current_col(yytext); return ')'; }
"+" { current_col(yytext); return '+'; }
"*" { current_col(yytext); return '*'; }

[ \t\r]+  { current_col(yytext); }
"//".*    { current_col(yytext); }
\n        { current_col(yytext); }
.         { current_col(yytext); }

%%

int yycolumn(void) { return yycol; }

