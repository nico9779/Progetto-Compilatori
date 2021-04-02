%option noyywrap
%{

#include <stdlib.h>

#include "interpreter_marco.tab.h"

extern YYSTYPE yylval;

%}

delim                   [ \t]
ws                      {delim}+
letter                  [A-Za-z]
digit                   [0-9]

number                  {digit}+\.?{digit}*

%%

"\n"					{ return yytext[0]; }
{ws}                    {}     /* eat up whitespaces */

"("	                    { printf("F<BR_ROUND_OPEN>\n"); return BR_ROUND_OPEN; }
")"	                    { printf("F<BR_ROUND_CLOSE>\n"); return BR_ROUND_CLOSE; }

"+"	                    { printf("F<OP_ADD>\n"); return OP_ADD; }
"-"	                    { printf("F<OP_SUB>\n"); return OP_SUB; }
"*"	                    { printf("F<OP_MUL>\n"); return OP_MUL; }
"/"	                    { printf("F<OP_DIV>\n"); return OP_DIV; }

{number}                {
							sscanf(yytext, "%lf", &yylval);
							printf("F<NUMBER, %s>\n", yytext);
							return NUMBER;
						}

%%