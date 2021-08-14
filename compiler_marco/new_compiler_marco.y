%debug

%{
#define YYDEBUG 1

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
	int counter = 0;
	int value = label_counter;
	while (value != 0)
	{
		value /= 10;
		counter++;
	}


	char* buffer = (char*)malloc(sizeof(char) * counter);
	if (!buffer)
		yyerror("Unable to allocate heap memory.");

	sprintf(buffer, "L%d", label_counter);
	label_counter++;

	return buffer;
}


char* next_var_name()
{
	int counter = 0;
	int value = var_counter;
	while (value != 0)
	{
		value /= 10;
		counter++;
	}


	char* buffer = (char*)malloc(sizeof(char) * counter);
	if (!buffer)
		yyerror("Unable to allocate heap memory.");

	sprintf(buffer, "t%d", var_counter);
	var_counter++;

	return buffer;
}


extern int yydebug;

symbol_table sym_table;


%}


%union
{
	struct
	{
		char* addr;
		char* type;
		
		char* next_label;
		char* true_label;
		char* false_label;
		char* cond_label;
	}address;
}


/* *** PUNCTUATORS *** */
%token <address> pt_comma
%token <address> pt_semicolon

/* *** KEYWORDS *** */
%token <address> kw_true
%token <address> kw_false

%token <address> kw_print

%token <address> kw_int

%token <address> kw_do
%token <address> kw_else
%token <address> kw_for
%token <address> kw_if
%token <address> kw_return
%token <address> kw_while

/* *** BRACKETS *** */
%token <address> br_round_open
%token <address> br_round_close
%token <address> br_curly_open
%token <address> br_curly_close

/* *** ARITHMETIC OPERATORS *** */
%token <address> op_add
%token <address> op_sub
%token <address> op_mul
%token <address> op_div
%token <address> op_mod

/* *** ASSIGNMENT OPERATORS *** */
%token <address> op_assign

/* *** RELATIONAL OPERATORS *** */
%token <address> op_eq
%token <address> op_ne
%token <address> op_lt
%token <address> op_le
%token <address> op_gt
%token <address> op_ge

/* *** LOGICAL OPERATORS *** */
%token <address> op_and
%token <address> op_or
%token <address> op_xor
%token <address> op_not

/* *** OTHERS *** */
%token <address> id
%token <address> int_number
%token <address> string


%type <address> PROGRAM
%type <address> BLOCK
%type <address> STATEMENT_LIST
%type <address> STATEMENT

%type <address> VAR_TYPE
%type <address> VAR_LIST

%type <address> START_IF_STATEMENT
%type <address> DUMMY_IF
%type <address> DUMMY_WHILE

%type <address> INT_EXPR
%type <address> BOOL_EXPR


%left op_add op_sub
%left op_mul op_div op_mod
%right op_uminus

%right op_assign

%nonassoc op_eq op_ne op_lt op_le op_gt op_ge
%left op_and op_or op_xor
%right op_not


%%


PROGRAM				:	STATEMENT_LIST								{}


BLOCK				:	br_curly_open STATEMENT_LIST br_curly_close	{}
					|	STATEMENT									{}
					;


STATEMENT_LIST		:	STATEMENT STATEMENT_LIST					{}
					|												{}
					;


STATEMENT			:	VAR_TYPE VAR_LIST pt_semicolon				{
																		//free($1.type);
																	}

					|	id op_assign INT_EXPR pt_semicolon			{
																		variable* var = findVariableInSymbolTable(&sym_table, $1.addr);
																		if (!var)
																		{
																			printf("ERROR: variable %s is not defined.\n", $1.addr);
																			exit(-1);
																		}

																		var->address = $3.addr;
																		printf("\t%s = %s\n", $1.addr, $3.addr);

																		//free($1.addr);
																	}

					|	kw_print br_round_open INT_EXPR br_round_close pt_semicolon
																	{
																		printf("\tprint(%s)\n", $3.addr);

																		free($3.addr);
																	}

					|	kw_print br_round_open BOOL_EXPR br_round_close pt_semicolon
																	{
																		printf("\tprint(%s)\n", $3.addr);

																		free($3.addr);
																	}

					|	START_IF_STATEMENT kw_else { $1.next_label = next_label_name(); printf("\tgoto %s\n", $1.next_label); printf("%s:\n", $1.false_label); } BLOCK { printf("%s:\n", $1.next_label); }
																	{
																		//free($1.next_label);
																		//free($1.true_label);
																		//free($1.false_label);
																	}

					|	START_IF_STATEMENT { printf("%s:\n", $1.next_label); }
																	{
																		//free($1.next_label);
																		//free($1.true_label);
																	}
					
					|	kw_while DUMMY_WHILE { printf("%s:\n", $2.cond_label); } br_round_open BOOL_EXPR br_round_close { printf("\tif %s goto %s\n", $5.addr, $2.true_label); printf("\tgoto %s\n", $2.next_label); printf("%s:\n", $2.true_label); } BLOCK { printf("\tgoto %s\n", $2.cond_label); printf("%s:\n", $2.next_label); }
																	{}
					;


START_IF_STATEMENT	:	kw_if DUMMY_IF br_round_open BOOL_EXPR br_round_close { printf("\tif %s goto %s\n", $4.addr, $2.true_label); printf("\tgoto %s\n", $2.false_label); printf("%s:\n", $2.true_label); } BLOCK
																	{
																		//free($4.addr);

																		$$.next_label = $2.next_label;
																		$$.true_label = $2.true_label;
																		$$.false_label = $2.false_label;
																		$$.cond_label = NULL;
																	}


DUMMY_IF			:												{
																		$$.true_label = next_label_name();
																		$$.next_label = next_label_name();
																		$$.false_label = $$.next_label;
																		$$.cond_label = NULL;
																	}


DUMMY_WHILE			:												{
																		$$.cond_label = next_label_name();
																		$$.true_label = next_label_name();
																		$$.next_label = next_label_name();
																		$$.false_label = NULL;
																	}


VAR_TYPE			:	kw_int										{
																		$$.type = strdup("int");
																	}
					;


VAR_LIST			:	VAR_LIST pt_comma id op_assign INT_EXPR		{
																		printf("\t%s %s\n", $<address>0.type, $3.addr);
																		printf("\t%s = %s\n", $3.addr, $5.addr);

																		addVariableToSymbolTable(&sym_table, $3.addr, $<address>0.type, $5.addr);

																		free($3.addr);
																		free($5.addr);
																	}

					|	VAR_LIST pt_comma id						{
																		printf("\t%s %s\n", $<address>0.type, $3.addr);

																		addVariableToSymbolTable(&sym_table, $3.addr, $<address>0.type, "0");

																		free($3.addr);
																	}

					|	id op_assign INT_EXPR						{
																		printf("\t%s %s\n", $<address>0.type, $1.addr);
																		printf("\t%s = %s\n", $1.addr, $3.addr);

																		addVariableToSymbolTable(&sym_table, $1.addr, $<address>0.type, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	id											{
																		printf("\t%s %s\n", $<address>0.type, $1.addr);

																		addVariableToSymbolTable(&sym_table, $1.addr, $<address>0.type, "0");

																		free($1.addr);
																	}
					;


INT_EXPR			:	INT_EXPR op_mul INT_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s * %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_div INT_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s / %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_mod INT_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s mod %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_add INT_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s + %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_sub INT_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s - %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	br_round_open INT_EXPR br_round_close		{
																		$$.addr = $2.addr;
																	}

					|	op_sub INT_EXPR %prec op_uminus				{
																		$$.addr = next_var_name();
																		printf("\t%s: -%s\n", $$.addr, $2.addr);

																		free($2.addr);
																	}

					|	id											{
																		if (!findVariableInSymbolTable(&sym_table, $1.addr))
																		{
																			printf("** ERROR: variable %s is not defined. **\n", $1.addr);
																			exit(-1);
																		}

																		$$.addr = next_var_name();
																		printf("\t%s: %s\n", $$.addr, $1.addr);

																		free($1.addr);
																	}

					|	int_number									{
																		$$.addr = next_var_name();
																		printf("\t%s: %s\n", $$.addr, $1.addr);

																		free($1.addr);
																	}
					;


BOOL_EXPR			:	BOOL_EXPR op_and BOOL_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s AND %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_or BOOL_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s OR %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_xor BOOL_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s XOR %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	op_not BOOL_EXPR							{
																		$$.addr = next_var_name();
																		printf("\t%s: NOT %s\n", $$.addr, $2.addr);

																		free($2.addr);
																	}

					|	BOOL_EXPR op_eq BOOL_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s == %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_ne BOOL_EXPR					{
																		$$.addr = next_var_name();
																		printf("\t%s: %s != %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_eq INT_EXPR						{
																		$$.addr = next_var_name();
																		printf("\t%s: %s == %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_ne INT_EXPR						{
																		$$.addr = next_var_name();
																		printf("\t%s: %s != %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_lt INT_EXPR						{
																		$$.addr = next_var_name();
																		printf("\t%s: %s < %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_le INT_EXPR						{
																		$$.addr = next_var_name();
																		printf("\t%s: %s <= %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_gt INT_EXPR						{
																		$$.addr = next_var_name();
																		printf("\t%s: %s > %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_ge INT_EXPR						{
																		$$.addr = next_var_name();
																		printf("\t%s: %s >= %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}
				
					|	br_round_open BOOL_EXPR br_round_close		{
																		$$.addr = $2.addr;
																	}

					|	kw_false									{
																		$$.addr = next_var_name();
																		printf("\t%s: FALSE\n", $$.addr);
																	}

					|	kw_true										{
																		$$.addr = next_var_name();
																		printf("\t%s: TRUE\n", $$.addr);
																	}

					;


%%

int main()
{
	yydebug = 0;

	allocateSymbolTable(&sym_table, 10);
	if (!sym_table.data)
	{
		fprintf(stderr, "Unable to allocate the symbol table.");
		return 0;
	}
		

	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit.");


	destroySymbolTable(&sym_table);
	return 0;
}

void yyerror(char* str)
{
	fprintf(stderr, "Parsing error: %s\n", str);

	destroySymbolTable(&sym_table);
	exit(0);
}