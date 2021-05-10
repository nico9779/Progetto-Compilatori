%{

/* Deccoment the line below to enable logging. */
//#define PROJECT_LOGGING

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(char* str);


int var_counter = 1;


char* next_var_name()
{
	static char buffer[5];
	sprintf(buffer, "t%d", var_counter);
    var_counter++;
    return buffer;
}


%}


%union
{
	struct
	{
		char* addr;
	}address;
}


/* *** PUNCTUATORS *** */
%token PT_SEMICOLON

/* *** KEYWORDS *** */
%token <address> KW_FALSE
%token KW_PRINT
%token <address> KW_TRUE

/* *** BRACKETS *** */
%token <address> BR_ROUND_OPEN
%token <address> BR_ROUND_CLOSE

/* *** ARITHMETIC OPERATORS *** */
%token <address> OP_ADD
%token <address> OP_SUB
%token <address> OP_MUL
%token <address> OP_DIV

/* *** ASSIGNMENT OPERATORS *** */
%token <address> OP_ASSIGN

/* *** RELATIONAL OPERATORS *** */
%token <address> OP_LT
%token <address> OP_LE
%token <address> OP_EQ
%token <address> OP_NE
%token <address> OP_GT
%token <address> OP_GE

/* *** LOGICAL OPERATORS *** */
%token <address> OP_AND
%token <address> OP_OR
%token <address> OP_XOR
%token <address> OP_NOT

/* *** OTHERS *** */
%token <address> NUMBER
%token <address> STRING


%type <address> float_expr
%type <address> bool_expr
%type <address> string_expr


%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS

%right OP_ASSIGN

%nonassoc OP_LT OP_LE OP_EQ OP_NE OP_GT OP_GE
%left OP_AND OP_OR OP_XOR
%right OP_NOT


%%


lines			:	lines KW_PRINT float_expr PT_SEMICOLON		{ free($3.addr); printf("\n"); }
				|	lines KW_PRINT bool_expr PT_SEMICOLON		{ free($3.addr); printf("\n"); }
				|	lines KW_PRINT string_expr PT_SEMICOLON		{ free($3.addr); printf("\n"); }
				|	lines float_expr PT_SEMICOLON				{ free($2.addr); printf("\n"); }
				|	lines bool_expr PT_SEMICOLON				{ free($2.addr); printf("\n"); }
				|
				;


float_expr		:	float_expr OP_MUL float_expr				{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_MUL float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s * %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_DIV float_expr				{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_DIV float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s / %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_ADD float_expr				{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_ADD float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s + %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_SUB float_expr				{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: float_expr OP_SUB float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s - %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	BR_ROUND_OPEN float_expr BR_ROUND_CLOSE		{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: BR_ROUND_OPEN float_expr BR_ROUND_CLOSE>\n");
																	#endif

																	$$.addr = strdup($2.addr);

																	free($2.addr);
																}

				|	OP_SUB float_expr %prec OP_UMINUS			{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: OP_SUB float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: -%s\n", new_var, $2.addr);
																	$$.addr = strdup(new_var);

																	free($2.addr);
																}

				|	NUMBER										{
																	#ifdef PROJECT_LOGGING
																		printf("B<float_expr: NUMBER, %s>\n", $1.addr);
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s\n", new_var, $1.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																}
				;


bool_expr		:	bool_expr OP_AND bool_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_AND bool_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s AND %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	bool_expr OP_OR bool_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_OR bool_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s OR %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	bool_expr OP_XOR bool_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_XOR bool_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s XOR %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	OP_NOT bool_expr							{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: OP_NOT bool_expr>\n");
																	#endif
																	
																	char* new_var = next_var_name();
																	printf("%s: NOT %s\n", new_var, $2.addr);
																	$$.addr = strdup(new_var);

																	free($2.addr);
																}

				|	bool_expr OP_EQ bool_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_EQ bool_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s == %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	bool_expr OP_NE bool_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: bool_expr OP_NE bool_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s != %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_LT float_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_LT float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s < %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_LE float_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_LE float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s <= %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_EQ float_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_EQ float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s == %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_NE float_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_NE float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s != %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_GT float_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_GT float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s > %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}

				|	float_expr OP_GE float_expr					{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: float_expr OP_GE float_expr>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s >= %s\n", new_var, $1.addr, $3.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
																	free($3.addr);
																}
				
				|	BR_ROUND_OPEN bool_expr BR_ROUND_CLOSE		{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: BR_ROUND_OPEN bool_expr BR_ROUND_CLOSE>\n");
																	#endif

																	$$.addr = strdup($2.addr);

																	free($2.addr);
																}

				|	KW_FALSE									{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: KW_FALSE>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: FALSE\n", new_var);
																	$$.addr = strdup(new_var);
																}

				|	KW_TRUE										{
																	#ifdef PROJECT_LOGGING
																		printf("B<bool_expr: KW_TRUE>\n");
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: TRUE\n", new_var);
																	$$.addr = strdup(new_var);
																}

				;


string_expr		:	STRING										{
																	#ifdef PROJECT_LOGGING
																		printf("B<string_expr: STRING, %s>\n", $1.addr);
																	#endif

																	char* new_var = next_var_name();
																	printf("%s: %s\n", new_var, $1.addr);
																	$$.addr = strdup(new_var);

																	free($1.addr);
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