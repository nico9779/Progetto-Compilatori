%{

#include <stdio.h>

#define YYSTYPE int

int yylex();
void yyerror(char* str);

%}

%token NUMBER

%token OP_ADD
%token OP_SUB
%token OP_MUL
%token OP_DIV

%token BR_ROUND_OPEN
%token BR_ROUND_CLOSE

%token SEMICOLON;

%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS

%%

line			:	expr SEMICOLON						{ printf("%d\n", $1); }
				;

expr			:	expr OP_MUL expr					{ $$ = $1 * $3; }
				|	expr OP_DIV expr					{ $$ = $1 / $3; }
				|	expr OP_ADD expr					{ $$ = $1 + $3; }
				|	expr OP_SUB expr					{ $$ = $1 - $3; }

				|	BR_ROUND_OPEN expr BR_ROUND_CLOSE	{ $$ = $2; }

				|	OP_SUB expr %prec OP_UMINUS			{ $$ = -$2; }

				|	NUMBER
				;

%%

int main()
{
	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit.");
	
	return 0;
}

void yyerror(char* str)
{
	fprintf(stderr, "Parsing error: %s\n", str);
}