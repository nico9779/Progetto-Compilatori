%{

/* Deccoment the line below to enable logging. */
//#define PROJECT_LOGGING

#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(char* str);

%}


%union
{
	double f_val;
	char* s_val;
}


/* *** PUNCTUATORS *** */
%token PT_SEMICOLON

/* *** KEYWORDS *** */
%token <f_val> KW_FALSE
%token KW_PRINT
%token <f_val> KW_TRUE

/* *** BRACKETS *** */
%token BR_ROUND_OPEN
%token BR_ROUND_CLOSE

/* *** ARITHMETIC OPERATORS *** */
%token OP_ADD
%token OP_SUB
%token OP_MUL
%token OP_DIV

/* *** ASSIGNMENT OPERATORS *** */
%token OP_ASSIGN

/* *** RELATIONAL OPERATORS *** */
%token OP_LT
%token OP_LE
%token OP_EQ
%token OP_NE
%token OP_GT
%token OP_GE

/* *** LOGICAL OPERATORS *** */
%token OP_AND
%token OP_OR
%token OP_XOR
%token OP_NOT

/* *** OTHERS *** */
%token <f_val> NUMBER
%token <s_val> STRING


%type <f_val> float_expr
%type <f_val> bool_expr
%type <s_val> string_expr


%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS

%right OP_ASSIGN

%nonassoc OP_LT OP_LE OP_EQ OP_NE OP_GT OP_GE
%left OP_AND OP_OR OP_XOR
%right OP_NOT


%%


lines			:	lines KW_PRINT float_expr PT_SEMICOLON		{ printf("%lf\n", $3); }
				|	lines KW_PRINT bool_expr PT_SEMICOLON		{ printf("%s\n", (($3 == 0.0) ? "false" : "true")); }
				|	lines KW_PRINT string_expr PT_SEMICOLON		{ printf("%s\n", $3); free($3); $3 = NULL; }
				|	lines float_expr PT_SEMICOLON				{ printf("%lf\n", $2); }
				|	lines bool_expr PT_SEMICOLON				{ printf("%s\n", (($2 == 0.0) ? "false" : "true")); }
				|
				;


float_expr		:	float_expr OP_MUL float_expr				{
																	$$ = $1 * $3;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_MUL float_expr, %lf>\n", $$);
																	#endif
																}

				|	float_expr OP_DIV float_expr				{
																	$$ = $1 / $3;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_DIV float_expr, %lf>\n", $$);
																	#endif
																}

				|	float_expr OP_ADD float_expr				{
																	$$ = $1 + $3;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_ADD float_expr, %lf>\n", $$);
																	#endif
																}

				|	float_expr OP_SUB float_expr				{
																	$$ = $1 - $3;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_SUB float_expr, %lf>\n", $$);
																	#endif
																}

				|	BR_ROUND_OPEN float_expr BR_ROUND_CLOSE		{
																	$$ = $2;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: BR_ROUND_OPEN float_expr BR_ROUND_CLOSE, %lf>\n", $$);
																	#endif
																}

				|	OP_SUB float_expr %prec OP_UMINUS			{
																	$$ = -$2;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: OP_SUB float_expr, %lf>\n", $$);
																	#endif
																}

				|	NUMBER										{
																	$$ = yylval.f_val;

																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: NUMBER, %lf>\n", $$);
																	#endif
																}
				;


bool_expr		:	bool_expr OP_AND bool_expr					{
																	$$ = (($1 != 0.0) && ($3 != 0.0)) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_AND bool_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	bool_expr OP_OR bool_expr					{
																	$$ = (($1 != 0.0) || ($3 != 0.0)) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_OR bool_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	bool_expr OP_XOR bool_expr					{
																	$$ = (($1 != 0.0) != ($3 != 0.0)) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_XOR bool_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	OP_NOT bool_expr							{
																	$$ = ($2 == 0.0) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: OP_NOT bool_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	bool_expr OP_EQ bool_expr					{
																	$$ = (($1 != 0.0) == ($3 != 0.0)) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_EQ bool_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	bool_expr OP_NE bool_expr					{
																	$$ = (($1 != 0.0) != ($3 != 0.0)) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_NE bool_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	float_expr OP_LT float_expr					{
																	$$ = ($1 < $3) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_LT float_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	float_expr OP_LE float_expr					{
																	$$ = ($1 <= $3) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_LE float_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	float_expr OP_EQ float_expr					{
																	$$ = ($1 == $3) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_EQ float_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	float_expr OP_NE float_expr					{
																	$$ = ($1 != $3) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_NE float_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	float_expr OP_GT float_expr					{
																	$$ = ($1 > $3) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_GT float_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	float_expr OP_GE float_expr					{
																	$$ = ($1 >= $3) ? 1.0 : 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_GE float_expr, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}
				
				|	BR_ROUND_OPEN bool_expr BR_ROUND_CLOSE		{
																	$$ = $2;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: BR_ROUND_OPEN bool_expr BR_ROUND_CLOSE, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	KW_FALSE									{
																	$$ = 0.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: KW_FALSE, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				|	KW_TRUE										{
																	$$ = 1.0;

																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: KW_TRUE, %s>\n",
																			(($$ == 0.0) ? "false" : "true"));
																	#endif
																}

				;


string_expr		:	STRING										{
																	$$ = yylval.s_val;

																	#ifdef PROJECT_LOGGING
																		printf("B<string_expr: STRING, %s>\n", $$);
																	#endif
																}


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