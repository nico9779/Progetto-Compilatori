%{


//Use it to enable debugging output, comment the line to disable it.
//#define PROJECT_LOGGING


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "uthash.h"

int yylex();
void yyerror(char* str);


//Logging function.
void LOG_Y(const char* str)
{
	#ifdef PROJECT_LOGGING
		printf("%s", str);
	#endif
}


int label_counter = 1;
int var_counter = 1;


char* next_label_name()
{
	int counter = 1;
	int value = label_counter;
	while (value != 0)
	{
		value /= 10;
		counter++;
	}


	char* buffer = (char*) malloc(sizeof(char) * counter);
	if (!buffer)
		yyerror("Unable to allocate heap memory.");

	sprintf(buffer, "L%d", label_counter);
	label_counter++;

	return buffer;
}


char* next_var_name()
{
	int counter = 1;
	int value = var_counter;
	while (value != 0)
	{
		value /= 10;
		counter++;
	}


	char* buffer = (char*) malloc(sizeof(char) * counter);
	if (!buffer)
		yyerror("Unable to allocate heap memory.");

	sprintf(buffer, "t%d", var_counter);
	var_counter++;

	return buffer;
}


typedef struct variable
{
	char* id;
	char* addr;
	char* type;
	UT_hash_handle hh;
}variable;

variable* symbol_table = NULL;


// Add variable to symbol table with initial value in "addr".
void addVar(char* id, char* addr, char* type)
{
    variable* tmp;
    HASH_FIND_STR(symbol_table, id, tmp);

    if(tmp == NULL)
	{
        tmp = (variable*) malloc(sizeof(variable));
        tmp->id = id;
        tmp->addr = addr;
		tmp->type = type;

        HASH_ADD_KEYPTR(hh, symbol_table, tmp->id, strlen(tmp->id), tmp);
    }
	else
	{
        printf("ERROR: multiple definition for variable %s\n", id);
        exit(-1);
    }
}


// Set address of a variable "id" in the symbol table.
void setVarAddr(char* id, char* addr)
{
    variable* tmp;
    HASH_FIND_STR(symbol_table, id, tmp);

    if(tmp == NULL)
	{
        printf("ERROR: variable %s is not defined\n", id);
        exit(-1);
    }

    tmp->addr = addr;
}


// Get address of a variable "id" in the symbol table.
char* getVarAddr(char* id)
{
    variable* tmp;
    HASH_FIND_STR(symbol_table, id, tmp);

    if(tmp == NULL)
	{
        printf("ERROR: variable %s is not defined\n", id);
        exit(-1);
    }

    return tmp->addr;
}


// Get type of a variable "id" in the symbol table.
char* getVarType(char* id)
{
    variable* tmp;
    HASH_FIND_STR(symbol_table, id, tmp);

    if(tmp == NULL)
	{
        printf("ERROR: variable %s is not defined\n", id);
        exit(-1);
    }

    return tmp->type;
}


// Return true (1) if a variable is in the symbol table else return false (0).
int isVarDefined(char* id)
{
    variable* tmp;
    HASH_FIND_STR(symbol_table, id, tmp);

    if(tmp == NULL)
        return 0;
	else
		return 1;
}


void printSymbolTable()
{
	for (variable* ptr = symbol_table; ptr != NULL; ptr = ptr->hh.next)
		printf("id: %s    type: %s    addr: %s\n", ptr->id, ptr->type, ptr->addr);

	printf("\n");
}


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
%token pt_comma
%token pt_semicolon

/* *** KEYWORDS *** */
%token kw_true
%token kw_false

%token kw_print

%token kw_int

%token kw_do
%token kw_else
%token kw_for
%token kw_if
%token kw_return
%token kw_while

/* *** BRACKETS *** */
%token br_round_open
%token br_round_close
%token br_curly_open
%token br_curly_close

/* *** ARITHMETIC OPERATORS *** */
%token op_add
%token op_sub
%token op_mul
%token op_div
%token op_mod

%token op_inc
%token op_dec

%token op_lsh
%token op_rsh

%token op_inv

/* *** ASSIGNMENT OPERATORS *** */
%token op_assign
%token op_mul_assign
%token op_div_assign
%token op_mod_assign
%token op_add_assign
%token op_sub_assign

/* *** RELATIONAL OPERATORS *** */
%token op_eq
%token op_ne
%token op_lt
%token op_le
%token op_gt
%token op_ge

/* *** LOGICAL OPERATORS *** */
%token op_and
%token op_or
%token op_xor
%token op_not

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
%right op_uminus op_inv

%nonassoc op_inc op_dec op_lsh op_rsh

%right op_assign

%nonassoc op_lt op_le op_gt op_ge
%right op_eq op_ne
%left op_and op_or op_xor
%right op_not


%%


PROGRAM				:	STATEMENT_LIST								{
																		LOG_Y("B<PROGRAM: STATEMENT_LIST>\n");
																		printf("\t<END>\n");
																	}


BLOCK				:	br_curly_open STATEMENT_LIST br_curly_close	{
																		LOG_Y("B<BLOCK: br_curly_open STATEMENT_LIST br_curly_close>\n");
																	}

					|	STATEMENT									{
																		LOG_Y("B<BLOCK: STATEMENT>\n");
																	}

					;


STATEMENT_LIST		:	STATEMENT STATEMENT_LIST					{
																		LOG_Y("B<STATEMENT_LIST: STATEMENT STATEMENT_LIST>\n");
																	}

					|												{
																		LOG_Y("B<STATEMENT_LIST: _>\n");
																	}
					;


STATEMENT			:	VAR_TYPE VAR_LIST pt_semicolon				{
																		LOG_Y("B<STATEMENT: VAR_TYPE VAR_LIST pt_semicolon>\n");

																		//free($1.type);
																	}

					|	id op_assign INT_EXPR pt_semicolon			{
																		LOG_Y("B<STATEMENT: id op_assign INT_EXPR pt_semicolon>\n");

																		setVarAddr($1.addr, $3.addr);

																		printf("\t\t%s = %s\n", $1.addr, $3.addr);

																		//free($1.addr);
																	}

					|	id op_mul_assign INT_EXPR pt_semicolon		{
																		LOG_Y("B<STATEMENT: id op_mul_assign INT_EXPR pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s * %s\n", new_var, $1.addr, $3.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		free($3.addr);
																		//free($1.addr);
																	}

					|	id op_div_assign INT_EXPR pt_semicolon		{
																		LOG_Y("B<STATEMENT: id op_div_assign INT_EXPR pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s / %s\n", new_var, $1.addr, $3.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		free($3.addr);
																		//free($1.addr);
																	}

					|	id op_mod_assign INT_EXPR pt_semicolon		{
																		LOG_Y("B<STATEMENT: id op_mod_assign INT_EXPR pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s mod %s\n", new_var, $1.addr, $3.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		free($3.addr);
																		//free($1.addr);
																	}

					|	id op_add_assign INT_EXPR pt_semicolon		{
																		LOG_Y("B<STATEMENT: id op_add_assign INT_EXPR pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s + %s\n", new_var, $1.addr, $3.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		free($3.addr);
																		//free($1.addr);
																	}

					|	id op_sub_assign INT_EXPR pt_semicolon		{
																		LOG_Y("B<STATEMENT: id op_sub_assign INT_EXPR pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s - %s\n", new_var, $1.addr, $3.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		free($3.addr);
																		//free($1.addr);
																	}

					|	id op_inc pt_semicolon						{
																		LOG_Y("B<STATEMENT: id op_inc pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s + 1\n", new_var, $1.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		//free($1.addr);
																	}

					|	op_inc id pt_semicolon						{
																		LOG_Y("B<STATEMENT: op_inc id pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($2.addr, new_var);

																		printf("\t\t%s = %s + 1\n", new_var, $2.addr);
																		printf("\t\t%s = %s\n", $2.addr, new_var);

																		//free($1.addr);
																	}

					|	id op_dec pt_semicolon						{
																		LOG_Y("B<STATEMENT: id op_dec pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		printf("\t\t%s = %s - 1\n", new_var, $1.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		//free($1.addr);
																	}

					|	op_dec id pt_semicolon						{
																		LOG_Y("B<STATEMENT: op_dec id pt_semicolon>\n");

																		char* new_var = next_var_name();
																		setVarAddr($2.addr, new_var);

																		printf("\t\t%s = %s - 1\n", new_var, $2.addr);
																		printf("\t\t%s = %s\n", $2.addr, new_var);

																		//free($1.addr);
																	}

					|	kw_print br_round_open INT_EXPR br_round_close pt_semicolon
																	{
																		LOG_Y("B<STATEMENT: kw_print br_round_open INT_EXPR br_round_close pt_semicolon>\n");

																		printf("\t\tprint(%s)\n", $3.addr);

																		free($3.addr);
																	}

					|	kw_print br_round_open BOOL_EXPR br_round_close pt_semicolon
																	{
																		LOG_Y("B<STATEMENT: kw_print br_round_open BOOL_EXPR br_round_close pt_semicolon>\n");

																		printf("\t\tprint(%s)\n", $3.addr);

																		free($3.addr);
																	}

					|	START_IF_STATEMENT kw_else { $1.next_label = next_label_name(); printf("\t\tgoto %s\n", $1.next_label); printf("\t%s:\n", $1.false_label); } BLOCK { printf("\t%s:\n", $1.next_label); }
																	{
																		LOG_Y("B<STATEMENT: kw_if br_round_open BOOL_EXPR br_round_close BLOCK kw_else BLOCK>\n");

																		free($1.next_label);
																		free($1.true_label);
																		free($1.false_label);
																	}

					|	START_IF_STATEMENT { printf("\t%s:\n", $1.next_label); }
																	{
																		LOG_Y("B<STATEMENT: kw_if br_round_open BOOL_EXPR br_round_close BLOCK>\n");

																		free($1.next_label);
																		free($1.true_label);
																	}
					
					|	kw_while DUMMY_WHILE { printf("\t%s:\n", $2.cond_label); } br_round_open BOOL_EXPR br_round_close { printf("\t\tif %s goto %s\n", $5.addr, $2.true_label); printf("\t\tgoto %s\n", $2.next_label); printf("\t%s:\n", $2.true_label); } BLOCK { printf("\t\tgoto %s\n", $2.cond_label); printf("\t%s:\n", $2.next_label); }
																	{
																		LOG_Y("B<STATEMENT: kw_while br_round_open BOOL_EXPR br_round_close BLOCK>\n");
																		
																		free($2.cond_label);
																		free($2.true_label);
																		free($2.next_label);
																	}
					;


START_IF_STATEMENT	:	kw_if DUMMY_IF br_round_open BOOL_EXPR br_round_close { printf("\t\tif %s goto %s\n", $4.addr, $2.true_label); printf("\t\tgoto %s\n", $2.false_label); printf("\t%s:\n", $2.true_label); } BLOCK
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
																		LOG_Y("B<VAR_TYPE: kw_int>\n");

																		$$.type = strdup("int");
																	}
					;


VAR_LIST			:	VAR_LIST pt_comma id op_assign INT_EXPR		{
																		LOG_Y("B<VAR_LIST: VAR_LIST pt_comma id op_assign INT_EXPR>\n");

																		printf("\t\t%s %s\n", $<address>0.type, $3.addr);
																		printf("\t\t%s = %s\n", $3.addr, $5.addr);

																		addVar($3.addr, $5.addr, $<address>0.type);

																		//free($3.addr);
																		//free($5.addr);
																	}

					|	VAR_LIST pt_comma id						{
																		LOG_Y("B<VAR_LIST: VAR_LIST pt_comma id>\n");

																		printf("\t\t%s %s\n", $<address>0.type, $3.addr);

																		addVar($3.addr, "0", $<address>0.type);

																		//free($3.addr);
																	}

					|	id op_assign INT_EXPR						{
																		LOG_Y("B<VAR_LIST: id op_assign INT_EXPR>\n");

																		printf("\t\t%s %s\n", $<address>0.type, $1.addr);
																		printf("\t\t%s = %s\n", $1.addr, $3.addr);

																		addVar($1.addr, $3.addr, $<address>0.type);

																		//free($1.addr);
																		//free($3.addr);
																	}

					|	id											{
																		LOG_Y("B<VAR_LIST: id>\n");

																		printf("\t\t%s %s\n", $<address>0.type, $1.addr);

																		addVar($1.addr, "0", $<address>0.type);

																		//free($1.addr);
																	}
					;


INT_EXPR			:	br_round_open INT_EXPR br_round_close		{
																		LOG_Y("B<INT_EXPR: br_round_open INT_EXPR br_round_close>\n");

																		$$.addr = $2.addr;
																	}

					|	id op_inc									{
																		LOG_Y("B<INT_EXPR: id op_inc>\n");

																		if(!isVarDefined($1.addr))
																		{
																			printf("\t** ERROR: variable %s is not defined. **\n", $1.addr);
																			exit(-1);
																		}

																		char* old_var = next_var_name();
																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		$$.addr = old_var;

																		printf("\t\t%s = %s\n", old_var, $1.addr);
																		printf("\t\t%s = %s + 1\n", new_var, $1.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		//free($1.addr);
																	}

					|	id op_dec									{
																		LOG_Y("B<INT_EXPR: id op_dec>\n");

																		if(!isVarDefined($1.addr))
																		{
																			printf("\t** ERROR: variable %s is not defined. **\n", $1.addr);
																			exit(-1);
																		}

																		char* old_var = next_var_name();
																		char* new_var = next_var_name();
																		setVarAddr($1.addr, new_var);

																		$$.addr = old_var;

																		printf("\t\t%s = %s\n", old_var, $1.addr);
																		printf("\t\t%s = %s - 1\n", new_var, $1.addr);
																		printf("\t\t%s = %s\n", $1.addr, new_var);

																		//free($1.addr);
																	}

					|	op_inc id									{
																		LOG_Y("B<INT_EXPR: op_inc id>\n");

																		if(!isVarDefined($2.addr))
																		{
																			printf("\t** ERROR: variable %s is not defined. **\n", $2.addr);
																			exit(-1);
																		}

																		char* new_var = next_var_name();
																		setVarAddr($2.addr, new_var);

																		$$.addr = $2.addr;
																		
																		printf("\t\t%s = %s + 1\n", new_var, $2.addr);
																		printf("\t\t%s = %s\n", $2.addr, new_var);

																		//free($1.addr);
																	}

					|	op_dec id									{
																		LOG_Y("B<INT_EXPR: op_dec id>\n");

																		if(!isVarDefined($2.addr))
																		{
																			printf("\t** ERROR: variable %s is not defined. **\n", $2.addr);
																			exit(-1);
																		}

																		char* new_var = next_var_name();
																		setVarAddr($2.addr, new_var);

																		$$.addr = $2.addr;

																		printf("\t\t%s = %s - 1\n", new_var, $2.addr);
																		printf("\t\t%s = %s\n", $2.addr, new_var);

																		//free($1.addr);
																	}

					|	op_add id									{
																		LOG_Y("B<INT_EXPR: op_add id>\n");

																		if(!isVarDefined($2.addr))
																		{
																			printf("\t** ERROR: variable %s is not defined. **\n", $2.addr);
																			exit(-1);
																		}

																		$$.addr = $2.addr;
																	}

					|	id											{
																		LOG_Y("B<INT_EXPR: id>\n");

																		if(!isVarDefined($1.addr))
																		{
																			printf("\t** ERROR: variable %s is not defined. **\n", $1.addr);
																			exit(-1);
																		}

																		$$.addr = $1.addr;
																	}

					|	op_add int_number							{
																		LOG_Y("B<INT_EXPR: op_add int_number>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s\n", $$.addr, $2.addr);

																		free($2.addr);
																	}

					|	int_number									{
																		LOG_Y("B<INT_EXPR: int_number>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s\n", $$.addr, $1.addr);

																		free($1.addr);
																	}

					|	op_sub INT_EXPR %prec op_uminus				{
																		LOG_Y("B<INT_EXPR: op_sub INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = -%s\n", $$.addr, $2.addr);

																		free($2.addr);
																	}

					|	op_inv INT_EXPR								{
																		LOG_Y("B<INT_EXPR: op_inv INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = ~%s\n", $$.addr, $2.addr);

																		free($2.addr);
																	}

					|	INT_EXPR op_mul INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_mul INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s * %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_div INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_div INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s / %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_mod INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_mod INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s mod %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_add INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_add INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s + %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_sub INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_sub INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s - %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_lsh INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_lsh INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s << %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_rsh INT_EXPR					{
																		LOG_Y("B<INT_EXPR: INT_EXPR op_rsh INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s >> %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}
					;


BOOL_EXPR			:	br_round_open BOOL_EXPR br_round_close		{
																		LOG_Y("B<BOOL_EXPR: br_round_open BOOL_EXPR br_round_close>\n");

																		$$.addr = $2.addr;
																	}

					|	kw_false									{
																		LOG_Y("B<BOOL_EXPR: kw_false>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = FALSE\n", $$.addr);
																	}

					|	kw_true										{
																		LOG_Y("B<BOOL_EXPR: kw_true>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = TRUE\n", $$.addr);
																	}

					|	op_not BOOL_EXPR							{
																		LOG_Y("B<BOOL_EXPR: op_not BOOL_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = NOT %s\n", $$.addr, $2.addr);

																		free($2.addr);
																	}

					|	INT_EXPR op_lt INT_EXPR						{
																		LOG_Y("B<BOOL_EXPR: INT_EXPR op_lt INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s < %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_le INT_EXPR						{
																		LOG_Y("B<BOOL_EXPR: INT_EXPR op_le INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s <= %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_gt INT_EXPR						{
																		LOG_Y("B<BOOL_EXPR: INT_EXPR op_gt INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s > %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_ge INT_EXPR						{
																		LOG_Y("B<BOOL_EXPR: INT_EXPR op_ge INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s >= %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_eq BOOL_EXPR					{
																		LOG_Y("B<BOOL_EXPR: BOOL_EXPR op_eq BOOL_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s == %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_ne BOOL_EXPR					{
																		LOG_Y("B<BOOL_EXPR: BOOL_EXPR op_ne BOOL_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s != %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_eq INT_EXPR						{
																		LOG_Y("B<BOOL_EXPR: INT_EXPR op_eq INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s == %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	INT_EXPR op_ne INT_EXPR						{
																		LOG_Y("B<BOOL_EXPR: INT_EXPR op_ne INT_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s != %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_xor BOOL_EXPR					{
																		LOG_Y("B<BOOL_EXPR: BOOL_EXPR op_xor BOOL_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s XOR %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_and BOOL_EXPR					{
																		LOG_Y("B<BOOL_EXPR: BOOL_EXPR op_and BOOL_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s AND %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}

					|	BOOL_EXPR op_or BOOL_EXPR					{
																		LOG_Y("B<BOOL_EXPR: BOOL_EXPR op_or BOOL_EXPR>\n");

																		$$.addr = next_var_name();
																		printf("\t\t%s = %s OR %s\n", $$.addr, $1.addr, $3.addr);

																		free($1.addr);
																		free($3.addr);
																	}
					;


%%

int main()
{
	printf("\n\t<START>\n");	

	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit.");

	return 0;
}

void yyerror(char* str)
{
	fprintf(stderr, "Parsing error: %s\n", str);
	exit(0);
}