%{

/* Deccoment the line below to enable logging. */
//#define PROJECT_LOGGING

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol_table.h"

int yylex();
void yyerror(char* str);


int label_counter = 1;
int var_counter = 1;


char* next_label_name()
{
	static char buffer[5];
	sprintf(buffer, "l%d", label_counter);
    label_counter++;
    return buffer;
}


char* next_var_name()
{
	static char buffer[5];
	sprintf(buffer, "t%d", var_counter);
    var_counter++;
    return buffer;
}


symbol_table sym_table;


%}


%union
{
	struct
	{
		char* addr;
		char* type;
		
		char* label_next;
		char* true_label;
		char* false_label;
	}address;
}


/* *** PUNCTUATORS *** */
%token <address> PT_COMMA
%token <address> PT_SEMICOLON

/* *** KEYWORDS *** */
%token <address> KW_TRUE
%token <address> KW_FALSE

%token <address> KW_PRINT

%token <address> KW_INT

%token <address> KW_DO
%token <address> KW_ELSE
%token <address> KW_FOR
%token <address> KW_IF
%token <address> KW_RETURN
%token <address> KW_WHILE

/* *** BRACKETS *** */
%token <address> BR_ROUND_OPEN
%token <address> BR_ROUND_CLOSE
%token <address> BR_CURLY_OPEN
%token <address> BR_CURLY_CLOSE

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
%token <address> ID
%token <address> NUMBER
%token <address> STRING


%type <address> program
%type <address> statement_list
%type <address> statement_or_block
%type <address> statement

%type <address> d1
%type <address> d2

%type <address> var_type
%type <address> var_list

%type <address> int_expr
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


program				:	statement_list								{
																		#ifdef PROJECT_LOGGING
																			printf("B<program: statement_list>\n");
																		#endif

																		printf("\n\n********** SYMBOL TABLE **********\n");
																		printSymbolTable(stdout, &sym_table);
																		printf("\n\n");
																	}


statement_list		:	statement statement_list					{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement_list: statement statement_list>\n");
																		#endif
																	}

					|												{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement_list: {}>\n");
																		#endif
																	}
					;


statement_or_block	:	statement									{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement_or_block: statement>\n");
																		#endif
																	}

					|	BR_CURLY_OPEN statement_list BR_CURLY_CLOSE	{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement_or_block: BR_CURLY_OPEN statement_list BR_CURLY_CLOSE>\n");
																		#endif
																	}
					;


statement			:	var_type var_list PT_SEMICOLON				{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement: var_type var_list PT_SEMICOLON>\n");
																		#endif
																	}

					|	ID OP_ASSIGN int_expr PT_SEMICOLON			{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement: ID OP_ASSIGN int_expr PT_SEMICOLON>\n");
																		#endif

																		variable* var = findVariableInSymbolTable(&sym_table, $1.addr);
																		if (!var)
																		{
																			printf("ERROR: variable %s is not defined.\n", $1.addr);
																			exit(-1);
																		}

																		var->address = $3.addr;
																		printf("\t%s = %s\n", $1.addr, $3.addr);
																	}

					|	KW_PRINT BR_ROUND_OPEN int_expr BR_ROUND_CLOSE PT_SEMICOLON
																	{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement: KW_PRINT BR_ROUND_OPEN int_expr BR_ROUND_CLOSE PT_SEMICOLON>\n");
																		#endif

																		printf("\tprint(%s)\n", $3.addr);
																	}
					
					|	KW_PRINT BR_ROUND_OPEN string_expr BR_ROUND_CLOSE PT_SEMICOLON
																	{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement: KW_PRINT BR_ROUND_OPEN string_expr BR_ROUND_CLOSE PT_SEMICOLON>\n");
																		#endif

																		printf("\tprint(%s)\n", $3.addr);
																	}

					|	d1 KW_IF BR_ROUND_OPEN bool_expr d2 BR_ROUND_CLOSE d3 statement_or_block KW_ELSE { $1.label_next = strdup(next_label_name()); printf("\tgoto %s\n", $1.label_next); printf("%s:\n", $1.false_label); } statement_or_block { printf("%s:\n", $1.label_next); }
																	{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement: d1 KW_IF BR_ROUND_OPEN bool_expr d2 BR_ROUND_CLOSE d3 statement_or_block KW_ELSE {} statement_or_block {}>\n");
																		#endif
																	}

					|	d1 KW_IF BR_ROUND_OPEN bool_expr d2 BR_ROUND_CLOSE d3 statement_or_block { printf("%s:\n", $1.label_next); }
																	{
																		#ifdef PROJECT_LOGGING
																			printf("B<statement: d1 KW_IF BR_ROUND_OPEN bool_expr d2 BR_ROUND_CLOSE d3 statement_or_block {}>\n");
																		#endif
																	}
					;


d1					:												{
																		$$.label_next = strdup(next_label_name());
																		$$.true_label = strdup(next_label_name());
																		$$.false_label = $$.label_next;
																	}

d2					:												{
																		printf("\tif %s goto %s\n", $<address>0.addr, $<address>-3.true_label);
																		printf("\tgoto %s\n", $<address>-3.false_label);
																	}

d3					:												{
																		printf("%s:\n", $<address>-5.true_label);
																	}


var_type			:	KW_INT										{
																		#ifdef PROJECT_LOGGING
																			printf("B<var_type: KW_INT>\n");
																		#endif

																		$$.type = strdup("int");
																	}
					;


var_list			:	var_list PT_COMMA ID						{
																		#ifdef PROJECT_LOGGING
																			printf("B<var_list: var_list PT_COMMA ID>\n");
																		#endif

																		addVariableToSymbolTable(&sym_table, $3.addr, $<address>0.type, "0");
																	}

					|	var_list PT_COMMA ID OP_ASSIGN int_expr		{
																		#ifdef PROJECT_LOGGING
																			printf("B<var_list: var_list PT_COMMA ID OP_ASSIGN int_expr>\n");
																		#endif

																		addVariableToSymbolTable(&sym_table, $3.addr, $<address>0.type, $5.addr);
																	}

					|	ID OP_ASSIGN int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<var_list: ID OP_ASSIGN int_expr>\n");
																		#endif

																		addVariableToSymbolTable(&sym_table, $1.addr, $<address>0.type, $3.addr);
																	}

					|	ID											{
																		#ifdef PROJECT_LOGGING
																			printf("B<var_list: ID>\n");
																		#endif

																		addVariableToSymbolTable(&sym_table, $1.addr, $<address>0.type, "0");
																	}
					;


int_expr			:	int_expr OP_MUL int_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: int_expr OP_MUL int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s * %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_DIV int_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: int_expr OP_DIV int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s / %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_ADD int_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: int_expr OP_ADD int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s + %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_SUB int_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: int_expr OP_SUB int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s - %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BR_ROUND_OPEN int_expr BR_ROUND_CLOSE		{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: BR_ROUND_OPEN int_expr BR_ROUND_CLOSE>\n");
																		#endif

																		$$.addr = strdup($2.addr);

																		free($2.addr);
																	}

					|	OP_SUB int_expr %prec OP_UMINUS				{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: OP_SUB int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: -%s\n", new_var, $2.addr);
																		$$.addr = strdup(new_var);

																		free($2.addr);
																	}

					|	ID											{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: ID, %s>\n", $1.addr);
																		#endif

																		if (!findVariableInSymbolTable(&sym_table, $1.addr))
																		{
																			printf("** ERROR: variable %s is not defined. **\n", $1.addr);
																			exit(-1);
																		}

																		char* new_var = next_var_name();
																		printf("\t%s: %s\n", new_var, $1.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																	}

					|	NUMBER										{
																		#ifdef PROJECT_LOGGING
																			printf("B<int_expr: NUMBER, %s>\n", $1.addr);
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s\n", new_var, $1.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																	}
					;


bool_expr			:	bool_expr OP_AND bool_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: bool_expr OP_AND bool_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s AND %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	bool_expr OP_OR bool_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: bool_expr OP_OR bool_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s OR %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	bool_expr OP_XOR bool_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: bool_expr OP_XOR bool_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s XOR %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	OP_NOT bool_expr							{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: OP_NOT bool_expr>\n");
																		#endif
																	
																		char* new_var = next_var_name();
																		printf("\t%s: NOT %s\n", new_var, $2.addr);
																		$$.addr = strdup(new_var);

																		free($2.addr);
																	}

					|	bool_expr OP_EQ bool_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: bool_expr OP_EQ bool_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s == %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	bool_expr OP_NE bool_expr					{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: bool_expr OP_NE bool_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s != %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_LT int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: int_expr OP_LT int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s < %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_LE int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: int_expr OP_LE int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s <= %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_EQ int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: int_expr OP_EQ int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s == %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_NE int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: int_expr OP_NE int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s != %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_GT int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: int_expr OP_GT int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s > %s\n", new_var, $1.addr, $3.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																		free($3.addr);
																	}

					|	int_expr OP_GE int_expr						{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: int_expr OP_GE int_expr>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s >= %s\n", new_var, $1.addr, $3.addr);
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
																		printf("\t%s: FALSE\n", new_var);
																		$$.addr = strdup(new_var);
																	}

					|	KW_TRUE										{
																		#ifdef PROJECT_LOGGING
																			printf("B<bool_expr: KW_TRUE>\n");
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: TRUE\n", new_var);
																		$$.addr = strdup(new_var);
																	}

					;


string_expr			:	STRING										{
																		#ifdef PROJECT_LOGGING
																			printf("B<string_expr: STRING, %s>\n", $1.addr);
																		#endif

																		char* new_var = next_var_name();
																		printf("\t%s: %s\n", new_var, $1.addr);
																		$$.addr = strdup(new_var);

																		free($1.addr);
																	}


%%

int main()
{
	allocateSymbolTable(&sym_table, 10);
	if (!sym_table.data)
	{
		fprintf(stderr, "Unable to allocate the symbol table.");
		return 0;
	}
		

	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit.");
	
	return 0;
}

void yyerror(char* str)
{
	fprintf(stderr, "Parsing error: %s\n", str);
}