%{

#include <stdio.h>

#define YYSTYPE double

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

%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS

%%

lines			:	lines expr '\n'						{ printf("%lf\n", $2); }
				|	lines '\n'
				|
				;

expr			:	expr OP_MUL expr					{ $$ = $1 * $3; printf("B<expr: expr OP_MUL expr, %lf>\n", $$); }
				|	expr OP_DIV expr					{ $$ = $1 / $3; printf("B<expr: expr OP_DIV expr, %lf>\n", $$); }
				|	expr OP_ADD expr					{ $$ = $1 + $3; printf("B<expr: expr OP_ADD expr, %lf>\n", $$); }
				|	expr OP_SUB expr					{ $$ = $1 - $3; printf("B<expr: expr OP_SUB expr, %lf>\n", $$); }

				|	BR_ROUND_OPEN expr BR_ROUND_CLOSE	{ $$ = $2; printf("B<expr: BR_ROUND_OPEN expr BR_ROUND_CLOSE, %lf>\n", $$); }

				|	OP_SUB expr %prec OP_UMINUS			{ $$ = -$2; printf("B<expr: OP_SUB expr, %lf>\n", $$); }

				|	NUMBER								{ $$ = yylval; printf("B<expr: NUMBER, %lf>\n", $$); }
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