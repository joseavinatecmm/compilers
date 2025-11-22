%option noyywrap
%option yylineno
%option nounput noinput

%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>

static int yycol = 1;
static void bumpcol(const char *yytext){
    for(const char *p=yytext; *p; ++p){
        if(*p=='\n') yycol = 1;
        else yycol++;
    }
}
int yycolumn(void){ return yycol; }
%}

WS        [ \t\r]+
DIGIT     [0-9]
ID_START  [A-Za-z_]
ID_CONT   [A-Za-z0-9_]
ICONST    {DIGIT}+
STRING    \"([^\"\\\n]|\\.)*\"

%%

^[ \t]*"#"include[ \t]*"<"[^>\n]+">" {
    bumpcol(yytext);
    /* Extrae ruta entre < > */

const char *start = strchr(yytext,'<');
    const char *end   = strrchr(yytext,'>');
    if(start && end && end>start){
        size_t n = (size_t)(end-start-1);
        char *path = (char*)malloc(n+1);
        memcpy(path, start+1, n);
        path[n] = '\0';
        yylval.sval = path;
        return T_INCLUDE;
    }
}

"int"      { bumpcol(yytext); return T_INT; }
"char"     { bumpcol(yytext); return T_CHAR; }
"return"   { bumpcol(yytext); return T_RETURN; }

{ICONST}   { bumpcol(yytext); yylval.ival = (int)strtol(yytext,NULL,10); return ICONST; }
{STRING}   { bumpcol(yytext); yylval.sval = strdup(yytext); return STRING; }

{ID_START}{ID_CONT}* { bumpcol(yytext); yylval.sval = strdup(yytext); return ID; }

"("  { bumpcol(yytext); return '('; }
")"  { bumpcol(yytext); return ')'; }
"{"  { bumpcol(yytext); return '{'; }
"}"  { bumpcol(yytext); return '}'; }
"["  { bumpcol(yytext); return '['; }
"]"  { bumpcol(yytext); return ']'; }
";"  { bumpcol(yytext); return ';'; }
","  { bumpcol(yytext); return ','; }
"*"  { bumpcol(yytext); return '*'; }
"="  { bumpcol(yytext); return '='; }

"//".*                 { bumpcol(yytext); /* skip */ }
"/*"([^*]|\*+[^*/])*"\*/" { bumpcol(yytext); /* skip */ }

{WS}     { bumpcol(yytext); }
\n       { bumpcol(yytext); }

.        { bumpcol(yytext); }

%%

