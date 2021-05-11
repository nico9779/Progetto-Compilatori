%{

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "uthash.h"

int yylex();
void yyerror(char* str);

int counter = 1;

char* next_var() {
    static char s[5];
    sprintf(s, "t%d", counter);
    counter++;
    return s;
}

typedef struct variable {
    const char* id;  // hash key
    char* addr;      // address of the value stored in the variable
    char* type;      // type of the variable
    UT_hash_handle hh;
} variable;

variable* symbolTable = NULL;

// Add variable to symbol table with initialization value in "init_value"
void addVar(char* id, char* init_value, char* type) {
    variable* tmp;
    HASH_FIND_STR(symbolTable, id, tmp);

    if(tmp == NULL) {
        tmp = (variable*) malloc(sizeof(variable));
        tmp->id = id;
        tmp->addr = init_value;
        tmp->type = type;
        
        HASH_ADD_KEYPTR(hh, symbolTable, tmp->id, strlen(tmp->id), tmp);
    } else {
        printf("ERROR: multiple definition for variable %s\n", id);
        exit(-1);
    }
}

// Set address of a variable "id" in the symbol table
void setVarAddr(char* id, char* addr){
    variable* tmp;
    HASH_FIND_STR(symbolTable, id, tmp);

    if(tmp == NULL) {
        printf("ERROR: variable %s is not defined\n", id);
        exit(-1);
    }

    tmp->addr = addr;
}

// Get address of a variable "id" in the symbol table
char* getVarAddr(char* id){
    variable* tmp;
    HASH_FIND_STR(symbolTable, id, tmp);

    if(tmp == NULL) {
        printf("ERROR: variable %s is not defined\n", id);
        exit(-1);
    }

    return tmp->addr;
}

// Get type of a variable "id" in the symbol table
char* getVarType(char* id){
    variable* tmp;
    HASH_FIND_STR(symbolTable, id, tmp);

    if(tmp == NULL) {
        printf("ERROR: variable %s is not defined\n", id);
        exit(-1);
    }

    return tmp->type;
}

// Return true (1) if a variable is in the symbol table else return false (0)
int isVarDefined(char* id){
    variable* tmp;
    HASH_FIND_STR(symbolTable, id, tmp);

    if(tmp == NULL) {
        return 0;
    }

    return 1;
}

%}

%union{
    struct address {
        char* addr;
        char* type;
    } address;
}

%token <address> NUMBER
%token <address> ID

%token KW_INT
%token KW_PRINT
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

%token OP_ASSIGN

%token BR_ROUND_OPEN
%token BR_ROUND_CLOSE

%token SEMICOLON
%token COMMA

%type <address> bool_expr
%type <address> int_expr
%type <address> type
%type <address> var_list

%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS


%left OP_OR OP_XOR
%left OP_AND
%right OP_NOT
%nonassoc OP_LT OP_LE OP_EQ OP_NEQ OP_GT OP_GE

%%

program			:	program stmt SEMICOLON					    { printf("\n"); }
				|
				;

stmt            :   type var_list                               { }

                |   ID OP_ASSIGN int_expr                       { 
                                                                    setVarAddr($1.addr, $3.addr);
                                                                    printf("%s = %s\n", $1.addr, $3.addr); 
                                                                }
                |   KW_PRINT BR_ROUND_OPEN ID BR_ROUND_CLOSE    {
                                                                    printf("%s : type = %s, addr = %s\n", $3.addr, getVarType($3.addr), getVarAddr($3.addr));
                                                                }
                ;

type            :   KW_INT                                      { 
                                                                    $$.type = strdup("int"); 
                                                                }
                ;

var_list        :   var_list COMMA ID                           {
                                                                    addVar($3.addr, "0", $<address>0.type);
                                                                    printf("%s %s\n", $<address>0.type, $3.addr);
                                                                }
                |   var_list COMMA ID OP_ASSIGN int_expr        {
                                                                    addVar($3.addr, $5.addr, $<address>0.type);
                                                                    printf("%s %s\n", $<address>0.type, $3.addr);
                                                                    printf("%s = %s\n", $3.addr, $5.addr);
                                                                }
                |   ID OP_ASSIGN int_expr                       {
                                                                    addVar($1.addr, $3.addr, $<address>0.type);
                                                                    printf("%s %s\n", $<address>0.type, $1.addr);
                                                                    printf("%s = %s\n", $1.addr, $3.addr);
                                                                }
                |   ID                                          {
                                                                    addVar($1.addr, "0", $<address>0.type);
                                                                    printf("%s %s\n", $<address>0.type, $1.addr);
                                                                }
                ;

bool_expr		:	bool_expr OP_AND bool_expr					{ 
																	char* temp = next_var();
                                                                    printf("%s = %s AND %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	bool_expr OP_OR bool_expr					{ 
																	char* temp = next_var();
                                                                    printf("%s = %s OR %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	bool_expr OP_XOR bool_expr					{
																	char* temp = next_var();
                                                                    printf("%s = %s XOR %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	OP_NOT bool_expr							{ 
																	char* temp = next_var();
                                                                    printf("%s = NOT %s\n", temp, $2.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	bool_expr OP_EQ bool_expr					{
																	char* temp = next_var();
                                                                    printf("%s = %s EQUAL %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	bool_expr OP_NEQ bool_expr					{
																	char* temp = next_var();
                                                                    printf("%s = %s NOT EQUAL %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	BR_ROUND_OPEN bool_expr BR_ROUND_CLOSE		{ 
																	$$.addr = strdup($2.addr);
																}
				|	int_expr OP_LT int_expr						{  
																	char* temp = next_var();
                                                                    printf("%s = %s < %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	int_expr OP_LE int_expr						{  
																	char* temp = next_var();
                                                                    printf("%s = %s <= %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	int_expr OP_GE int_expr						{  
																	char* temp = next_var();
                                                                    printf("%s = %s >= %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	int_expr OP_GT int_expr						{  
																	char* temp = next_var();
                                                                    printf("%s = %s > %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}	
				|	int_expr OP_EQ int_expr						{  
																	char* temp = next_var();
                                                                    printf("%s = %s EQUAL %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	int_expr OP_NEQ int_expr					{  
																	char* temp = next_var();
                                                                    printf("%s = %s NOT EQUAL %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
																}
				|	KW_TRUE										{
                                                                    char* temp = next_var();
                                                                    printf("%s = TRUE\n", temp);
                                                                    $$.addr = strdup(temp);  
																}	
				|	KW_FALSE									{
																	char* temp = next_var();
                                                                    printf("%s = FALSE\n", temp);
                                                                    $$.addr = strdup(temp);  
																}																														
				;

int_expr		:	int_expr OP_MUL int_expr					{   
                                                                    char* temp = next_var();
                                                                    printf("%s = %s * %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
                                                                }
				|	int_expr OP_DIV int_expr					{   
                                                                    char* temp = next_var();
                                                                    printf("%s = %s / %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
                                                                }
				|	int_expr OP_ADD int_expr					{   
                                                                    char* temp = next_var();
                                                                    printf("%s = %s + %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp);  
                                                                }
				|	int_expr OP_SUB int_expr					{   
                                                                    char* temp = next_var();
                                                                    printf("%s = %s - %s\n", temp, $1.addr, $3.addr);
                                                                    $$.addr = strdup(temp); 
                                                                }

				|	BR_ROUND_OPEN int_expr BR_ROUND_CLOSE		{ $$.addr = strdup($2.addr); }

				|	OP_SUB int_expr %prec OP_UMINUS				{ 
                                                                    char* temp = next_var();
                                                                    printf("%s = -%s\n", temp, $2.addr);
                                                                    $$.addr = strdup(temp); 
                                                                }
                |   OP_ADD  ID                                  {
                                                                    if(!isVarDefined($2.addr)){
                                                                        printf("ERROR : variable %s is not defined\n", $2.addr);
                                                                        exit(-1);
                                                                    }
                                                                    $$.addr = strdup($2.addr);
                                                                }                 
				|	OP_ADD	NUMBER								{ 
                                                                    $$.addr = strdup($2.addr); 
                                                                }
                |   ID                                          {
                                                                    if(!isVarDefined($1.addr)){
                                                                        printf("ERROR : variable %s is not defined\n", $1.addr);
                                                                        exit(-1);
                                                                    }
                                                                    $$.addr = strdup($1.addr);
                                                                }
				|	NUMBER										{   
                                                                    $$.addr = strdup($1.addr); 
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