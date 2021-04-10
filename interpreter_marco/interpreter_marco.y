%{

#include <stdio.h>

/*#define PROJECT_LOGGING*/

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

expr			:	expr OP_MUL expr					{
															$$ = $1 * $3;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: expr OP_MUL expr, %lf>\n", $$);
															#endif
														}

				|	expr OP_DIV expr					{
															$$ = $1 / $3;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: expr OP_DIV expr, %lf>\n", $$);
															#endif
														}

				|	expr OP_ADD expr					{
															$$ = $1 + $3;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: expr OP_ADD expr, %lf>\n", $$);
															#endif
														}

				|	expr OP_SUB expr					{
															$$ = $1 - $3;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: expr OP_SUB expr, %lf>\n", $$);
															#endif
														}

				|	BR_ROUND_OPEN expr BR_ROUND_CLOSE	{
															$$ = $2;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: BR_ROUND_OPEN expr BR_ROUND_CLOSE, %lf>\n", $$);
															#endif
														}

				|	OP_SUB expr %prec OP_UMINUS			{
															$$ = -$2;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: OP_SUB expr, %lf>\n", $$);
															#endif
														}

				|	NUMBER								{
															$$ = yylval;
															
															#ifdef PROJECT_LOGGING
																printf("B<expr: NUMBER, %lf>\n", $$);
															#endif
														}
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