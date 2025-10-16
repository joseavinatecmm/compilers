%{
#include <stdio.h>
#include <string.h>

int token_count = 0;
int line_count = 1;

#define MAXTOKENS 2000

typedef struct {
    char lexeme[128];
    char type[50];
    int line;
} Token;

Token tokens[MAXTOKENS];

void addToken(const char *type, const char *lexeme, int line) {
    if (token_count < MAXTOKENS) {
        strcpy(tokens[token_count].type, type);
        strcpy(tokens[token_count].lexeme, lexeme);
        tokens[token_count].line = line;
        token_count++;
    }
}
%}

%option noyywrap

alpha [a-zA-Z_]
digit [0-9]
ws [ \t]+

%%

^"#ifndef"[ \t]+{alpha}({alpha}|{digit}|_)*   { addToken("IFNDEF", yytext, line_count); }
^"#define"[ \t]+{alpha}({alpha}|{digit}|_)*   { addToken("DEFINE", yytext, line_count); }
^"#endif"                                     { addToken("ENDIF", yytext, line_count); }

"class"[ \t]+{alpha}({alpha}|{digit}|_)*      { addToken("CLASS_DEF", yytext, line_count); }

"private:"                                    { addToken("PRIVATE_SECTION", yytext, line_count); }
"protected:"                                  { addToken("PROTECTED_SECTION", yytext, line_count); }
"public:"                                     { addToken("PUBLIC_SECTION", yytext, line_count); }

"int"[ \t]+{alpha}({alpha}|{digit}|_)*";"     { addToken("INT_ATTRIBUTE", yytext, line_count); }
"float"[ \t]+{alpha}({alpha}|{digit}|_)*";"   { addToken("FLOAT_ATTRIBUTE", yytext, line_count); }

"void"[ \t]+{alpha}({alpha}|{digit}|_)*[ \t]*"("[ \t]*"float"[ \t]+{alpha}({alpha}|{digit}|_)*([ \t]*","[ \t]*"float"[ \t]+{alpha}({alpha}|{digit}|_)*)*[ \t]*")"";" {
    addToken("VOID_METHOD_FLOAT_PARAMS", yytext, line_count);
}

({alpha}({alpha}|{digit}|_)*([ \t]*\*)?[ \t]+){alpha}({alpha}|{digit}|_)*[ \t]*"("[^)]*")"[ \t]*";" {
    addToken("METHOD_DECLARATION", yytext, line_count);
}

"{"                                           { addToken("LBRACE", yytext, line_count); }
"};"                                          { addToken("RBRACE_ENDCLASS", yytext, line_count); }

{alpha}({alpha}|{digit}|_)*                   { addToken("IDENTIFIER", yytext, line_count); }
{digit}+                                      { addToken("NUMBER", yytext, line_count); }

\n                                            { line_count++; }
{ws}                                          { }

.                                             { addToken("SYMBOL", yytext, line_count); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("No se pudo abrir el archivo"); return 1; }
        yyin = f;
    }

    yylex();

    printf("\n%-28s %-40s %-5s\n", "TOKEN", "LEXEME", "LINE");
    printf("-------------------------------------------------------------------------------\n");
    for (int i = 0; i < token_count; i++) {
        printf("%-28s %-40s %-5d\n", tokens[i].type, tokens[i].lexeme, tokens[i].line);
    }

    printf("\n>>> Total de líneas leídas: %d\n", line_count);
    return 0;
}

