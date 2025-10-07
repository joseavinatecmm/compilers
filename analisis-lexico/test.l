%{
#include <stdio.h>
int countn = 0;

/* Tokens simulados */
#define PRINTFF     256
#define SCANFF      257
#define INT         258
#define FLOAT       259
#define CHAR        260
#define VOID        261
#define RETURN      262
#define FOR         263
#define IF          264
#define ELSE        265
#define INCLUDE     266
#define TRUE        267
#define FALSE       268
#define NUMBER      269
#define FLOAT_NUM   270
#define ID          271
#define UNARY       272
#define LE          273
#define GE          274
#define EQ          275
#define NE          276
#define GT          277
#define LT          278
#define AND         279
#define OR          280
#define ADD         281
#define SUBTRACT    282
#define DIVIDE      283
#define MULTIPLY    284
#define STR         285
#define CHARACTER   286
%}

%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"printf"                    { printf("TOKEN: PRINTFF (%s)\n", yytext); return PRINTFF; }
"scanf"                     { printf("TOKEN: SCANFF (%s)\n", yytext); return SCANFF; }
"int"                       { printf("TOKEN: INT (%s)\n", yytext); return INT; }
"float"                     { printf("TOKEN: FLOAT (%s)\n", yytext); return FLOAT; }
"char"                      { printf("TOKEN: CHAR (%s)\n", yytext); return CHAR; }
"void"                      { printf("TOKEN: VOID (%s)\n", yytext); return VOID; }
"return"                    { printf("TOKEN: RETURN (%s)\n", yytext); return RETURN; }
"for"                       { printf("TOKEN: FOR (%s)\n", yytext); return FOR; }
"if"                        { printf("TOKEN: IF (%s)\n", yytext); return IF; }
"else"                      { printf("TOKEN: ELSE (%s)\n", yytext); return ELSE; }
^"#include"[ ]*<[^>]+\.h>   { printf("TOKEN: INCLUDE (%s)\n", yytext); return INCLUDE; }
"true"                      { printf("TOKEN: TRUE (%s)\n", yytext); return TRUE; }
"false"                     { printf("TOKEN: FALSE (%s)\n", yytext); return FALSE; }

[-]?{digit}+                { printf("TOKEN: NUMBER (%s)\n", yytext); return NUMBER; }
[-]?{digit}+\.{digit}+      { printf("TOKEN: FLOAT_NUM (%s)\n", yytext); return FLOAT_NUM; }
{alpha}({alpha}|{digit})*   { printf("TOKEN: ID (%s)\n", yytext); return ID; }
{unary}                     { printf("TOKEN: UNARY (%s)\n", yytext); return UNARY; }

"<="                        { printf("TOKEN: LE (%s)\n", yytext); return LE; }
">="                        { printf("TOKEN: GE (%s)\n", yytext); return GE; }
"=="                        { printf("TOKEN: EQ (%s)\n", yytext); return EQ; }
"!="                        { printf("TOKEN: NE (%s)\n", yytext); return NE; }
">"                         { printf("TOKEN: GT (%s)\n", yytext); return GT; }
"<"                         { printf("TOKEN: LT (%s)\n", yytext); return LT; }
"&&"                        { printf("TOKEN: AND (%s)\n", yytext); return AND; }
"||"                        { printf("TOKEN: OR (%s)\n", yytext); return OR; }

"+"                         { printf("TOKEN: ADD (%s)\n", yytext); return ADD; }
"-"                         { printf("TOKEN: SUBTRACT (%s)\n", yytext); return SUBTRACT; }
"/"                         { printf("TOKEN: DIVIDE (%s)\n", yytext); return DIVIDE; }
"*"                         { printf("TOKEN: MULTIPLY (%s)\n", yytext); return MULTIPLY; }

/* Comentarios */
"//"[^\n]*                  { /* comentario de línea */ }
"/*"([^*]|\*+[^/])*"*/"     { /* comentario de bloque */ }

/* Espacios y tabs */
[ \t]+                      { ; }

/* Salto de línea */
\n                          { countn++; }

/* Strings y chars */
\"[^"\n]*\"                 { printf("TOKEN: STR (%s)\n", yytext); return STR; }
\'[^'\n]\'                  { printf("TOKEN: CHARACTER (%s)\n", yytext); return CHARACTER; }

/* Cualquier otro carácter */
.                           { printf("UNKNOWN: (%s)\n", yytext); }

%%

int yywrap(void) {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("No se pudo abrir el archivo"); return 1; }
        yyin = f;
    }

    yylex();  /* procesa todo hasta EOF */

    printf("\n>>> Total de líneas leídas: %d\n", countn);
    return 0;
}

