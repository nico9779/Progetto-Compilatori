%{

#include <stdio.h>

#define YYSTYPE int

int yylex();
void yyerror(char* str);

%}

%token NUMBER

%token KW_FALSE
%token KW_TRUE

%token OP_ADD
%token OP_SUB
%token OP_MUL
%token OP_DIV

%token OP_LT
%token OP_LE
%token OP_EQ
%token OP_NEQ
%token OP_GT
%token OP_GE

%token OP_AND
%token OP_OR
%token OP_XOR
%token OP_NOT

%token BR_ROUND_OPEN
%token BR_ROUND_CLOSE

%token SEMICOLON;



%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS


%left OP_OR OP_XOR
%left OP_AND
%right OP_NOT
%nonassoc OP_LT OP_LE OP_EQ OP_NEQ OP_GT OP_GE

%%

line			:	line bool_expr SEMICOLON					{ 
																	if($2 == 1)
																		printf("true\n");
																	else
																		printf("false\n");
 																}
				|	line int_expr SEMICOLON						{ printf("%d\n", $2); }
				|
				;

bool_expr		:	bool_expr OP_AND bool_expr					{ 
																	if ($1 == 1 && $3 == 1)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	bool_expr OP_OR bool_expr					{ 
																	if ($1 == 1 || $3 == 1)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	bool_expr OP_XOR bool_expr					{
																	if(($1 == 1) != ($3 == 1))
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	OP_NOT bool_expr							{ 
																	if ($2 == 1)
																		$$ = 0;
																	else
																		$$ = 1;
																}
				|	bool_expr OP_EQ bool_expr					{
																	if(($1 == 1) == ($3 == 1))
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	bool_expr OP_NEQ bool_expr					{
																	if(($1 == 1) != ($3 == 1))
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	BR_ROUND_OPEN bool_expr BR_ROUND_CLOSE		{ 
																	$$ = $2;
																}
				|	int_expr OP_LT int_expr						{  
																	if($1 < $3)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	int_expr OP_LE int_expr						{  
																	if($1 <= $3)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	int_expr OP_GE int_expr						{  
																	if($1 >= $3)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	int_expr OP_GT int_expr						{  
																	if($1 > $3)
																		$$ = 1;
																	else
																		$$ = 0;
																}	
				|	int_expr OP_EQ int_expr						{  
																	if($1 == $3)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	int_expr OP_NEQ int_expr					{  
																	if($1 != $3)
																		$$ = 1;
																	else
																		$$ = 0;
																}
				|	KW_TRUE										{
																	$$ = 1;
																}	
				|	KW_FALSE									{
																	$$ = 0;
																}																														
				;

int_expr		:	int_expr OP_MUL int_expr					{ $$ = $1 * $3; }
				|	int_expr OP_DIV int_expr					{ $$ = $1 / $3; }
				|	int_expr OP_ADD int_expr					{ $$ = $1 + $3; }
				|	int_expr OP_SUB int_expr					{ $$ = $1 - $3; }

				|	BR_ROUND_OPEN int_expr BR_ROUND_CLOSE		{ $$ = $2; }

				|	OP_SUB int_expr %prec OP_UMINUS				{ $$ = -$2; }

				|	OP_ADD	NUMBER								{ $$ = yylval; }
				|	NUMBER										{ $$ = yylval; }
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