%{

#include <stdio.h>
#include <string.h>
#include "uthash.h"

int yylex();
void yyerror(char* str);

int var_counter = 1;
int label_counter = 1;

// Function to create next temporary variable
char* next_var() {
    
    int digits = 0;
	int value = var_counter;
	while (value != 0) {
		value /= 10;
		digits++;
	}

	char* buffer = (char*) malloc(sizeof(char) * (digits+1));
	if (buffer == NULL){
        printf("Unable to allocate heap memory.");
        exit(-1);
    }
        
    sprintf(buffer, "t%d", var_counter);
    var_counter++;

    return buffer;
}

// Function to create next label
char* next_label() {
    
    int digits = 0;
	int value = label_counter;
	while (value != 0) {
		value /= 10;
		digits++;
	}

	char* buffer = (char*) malloc(sizeof(char) * (digits+1));
	if (buffer == NULL){
        printf("Unable to allocate heap memory.");
        exit(-1);
    }

    sprintf(buffer, "L%d", label_counter);
    label_counter++;
    
    return buffer;
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
        char* addr;             // address of a variable that contain the result of an expression
        char* type;             // type of a declared variable
        char* next;             // label next
        char* true_label;       // true label of a boolean expression
        char* false_label;      // false label of a boolean expression
        char* begin;            // begin label of a while instruction
    } address;
}

%token <address> number
%token <address> id

%token kw_int
%token kw_if
%token kw_else
%token kw_while
%token kw_false
%token kw_true
%token kw_print

%token op_add
%token op_sub
%token op_mul
%token op_div

%token op_lt
%token op_le
%token op_eq
%token op_neq
%token op_gt
%token op_ge
%token op_increment
%token op_decrement

%token op_and
%token op_or
%token op_xor
%token op_not

%token op_assign

%token br_round_open
%token br_round_close
%token br_curly_open
%token br_curly_close

%token pt_semicolon
%token pt_comma


%type <address> PROGRAM
%type <address> STMT_LIST
%type <address> BLOCK
%type <address> STMT
%type <address> VAR_TYPE
%type <address> VAR_LIST
%type <address> START_IF_STMT
%type <address> DUMMY_IF
%type <address> DUMMY_WHILE
%type <address> BOOL_EXPR
%type <address> INT_EXPR

%left op_add op_sub
%left op_mul op_div
%right op_uminus

%right op_assign

%right op_eq op_neq
%left op_or op_xor
%left op_and
%right op_not
%nonassoc op_lt op_le op_gt op_ge

%%

PROGRAM			    :	STMT_LIST					                                    { printf("end\n"); }

STMT_LIST           :   STMT STMT_LIST                                                  { }                                     
                    |   /* empty */                                                     { }                     
                    ;

BLOCK               :   STMT                                                            { }
                    |   br_curly_open STMT_LIST br_curly_close                          { }
                    ;

STMT                :   VAR_TYPE VAR_LIST pt_semicolon                                  { }

                    |   id op_assign INT_EXPR pt_semicolon                              { 
                                                                                            setVarAddr($1.addr, $3.addr);
                                                                                            printf("%s = %s\n", $1.addr, $3.addr); 
                                                                                        }
                    
                    |   id op_increment pt_semicolon                                    {
                                                                                            char* temp = next_var();
                                                                                            setVarAddr($1.addr, temp);
                                                                                            printf("%s = %s + 1\n", temp, $1.addr);
                                                                                            printf("%s = %s\n", $1.addr, temp);
                                                                                        }

                    |   id op_decrement pt_semicolon                                    {
                                                                                            char* temp = next_var();
                                                                                            setVarAddr($1.addr, temp);
                                                                                            printf("%s = %s - 1\n", temp, $1.addr);
                                                                                            printf("%s = %s\n", $1.addr, temp);
                                                                                        }

                    |   kw_print br_round_open INT_EXPR br_round_close pt_semicolon     {
                                                                                            printf("print(%s)\n", $3.addr);
                                                                                        }

                    |	kw_print br_round_open BOOL_EXPR br_round_close pt_semicolon    {
                                                                                            printf("print(%s)\n", $3.addr);
                                                                                        }

                    |   START_IF_STMT kw_else { $1.next = next_label(); printf("goto %s\n", $1.next); printf("%s : ", $1.false_label); } BLOCK { printf("%s : ", $1.next); }

                    |   START_IF_STMT { printf("%s : ", $1.next); }

                    |   DUMMY_WHILE kw_while br_round_open BOOL_EXPR br_round_close PRINT_IF_EXPR BLOCK { printf("goto %s\n", $1.begin); printf("%s : ", $1.next); }
                    ;

START_IF_STMT       :   DUMMY_IF kw_if br_round_open BOOL_EXPR br_round_close PRINT_IF_EXPR BLOCK   {
                                                                                                        $$.next = $1.next;
                                                                                                        $$.true_label = $1.true_label;
                                                                                                        $$.false_label = $1.false_label;
                                                                                                    }


DUMMY_IF            :   {
                            char* next = next_label();
                            $$.next = next;
                            $$.true_label = next_label();
                            $$.false_label = next;
                        }

DUMMY_WHILE         :   { 
                            char* next = next_label();
                            $$.next = next;
                            char* begin = next_label();
                            $$.begin = begin;
                            $$.true_label = next_label(); 
                            $$.false_label = next;
                            printf("%s : ", begin);
                        }

PRINT_IF_EXPR       :   {
                            printf("if %s goto %s\n", $<address>-1.addr, $<address>-4.true_label); 
                            printf("goto %s\n", $<address>-4.false_label); 
                            printf("%s : ", $<address>-4.true_label);
                        }

VAR_TYPE            :   kw_int                                      { 
                                                                        $$.type = strdup("int"); 
                                                                    }
                    ;

VAR_LIST            :   VAR_LIST pt_comma id                        {
                                                                        addVar($3.addr, "0", $<address>0.type);
                                                                        printf("%s %s\n", $<address>0.type, $3.addr);
                                                                    }
                    |   VAR_LIST pt_comma id op_assign INT_EXPR     {
                                                                        addVar($3.addr, $5.addr, $<address>0.type);
                                                                        printf("%s %s\n", $<address>0.type, $3.addr);
                                                                        printf("%s = %s\n", $3.addr, $5.addr);
                                                                    }
                    |   id op_assign INT_EXPR                       {
                                                                        addVar($1.addr, $3.addr, $<address>0.type);
                                                                        printf("%s %s\n", $<address>0.type, $1.addr);
                                                                        printf("%s = %s\n", $1.addr, $3.addr);
                                                                    }
                    |   id                                          {
                                                                        addVar($1.addr, "0", $<address>0.type);
                                                                        printf("%s %s\n", $<address>0.type, $1.addr);
                                                                    }
                    ;

BOOL_EXPR		    :	BOOL_EXPR op_and BOOL_EXPR					{ 
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s AND %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }
                    |	BOOL_EXPR op_or BOOL_EXPR					{ 
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s OR %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }
                    |	BOOL_EXPR op_xor BOOL_EXPR					{
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s XOR %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }
                    |	op_not BOOL_EXPR							{ 
                                                                        $$.addr = next_var();
                                                                        printf("%s = NOT %s\n", $$.addr, $2.addr);                                                                     
                                                                    }
                    |	BOOL_EXPR op_eq BOOL_EXPR					{
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s EQUAL %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }
                    |	BOOL_EXPR op_neq BOOL_EXPR					{
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s NOT EQUAL %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }
                    |	br_round_open BOOL_EXPR br_round_close		{ 
                                                                        $$.addr = $2.addr;
                                                                    }
                    |	INT_EXPR op_lt INT_EXPR						{  
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s < %s\n", $$.addr, $1.addr, $3.addr);                                                                    
                                                                    }
                    |	INT_EXPR op_le INT_EXPR						{  
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s <= %s\n", $$.addr, $1.addr, $3.addr);                                                                  
                                                                    }
                    |	INT_EXPR op_ge INT_EXPR						{  
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s >= %s\n", $$.addr, $1.addr, $3.addr);      
                                                                    }
                    |	INT_EXPR op_gt INT_EXPR						{  
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s > %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }	
                    |	INT_EXPR op_eq INT_EXPR						{  
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s EQUAL %s\n", $$.addr, $1.addr, $3.addr);   
                                                                    }
                    |	INT_EXPR op_neq INT_EXPR					{  
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s NOT EQUAL %s\n", $$.addr, $1.addr, $3.addr);   
                                                                    }
                    |	kw_true										{
                                                                        $$.addr = next_var();
                                                                        printf("%s = TRUE\n", $$.addr);   
                                                                    }	
                    |	kw_false									{
                                                                        $$.addr = next_var();
                                                                        printf("%s = FALSE\n", $$.addr);           
                                                                    }																														
                    ;

INT_EXPR		    :	INT_EXPR op_mul INT_EXPR					{   
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s * %s\n", $$.addr, $1.addr, $3.addr);  
                                                                    }
                    |	INT_EXPR op_div INT_EXPR					{   
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s / %s\n", $$.addr, $1.addr, $3.addr);                                                                     
                                                                    }
                    |	INT_EXPR op_add INT_EXPR					{   
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s + %s\n", $$.addr, $1.addr, $3.addr);                                                                    
                                                                    }
                    |	INT_EXPR op_sub INT_EXPR					{   
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s - %s\n", $$.addr, $1.addr, $3.addr);                                                                   
                                                                    }

                    |	br_round_open INT_EXPR br_round_close		{ $$.addr = $2.addr; }

                    |	op_sub INT_EXPR %prec op_uminus				{ 
                                                                        $$.addr = next_var();
                                                                        printf("%s = -%s\n", $$.addr, $2.addr);                                                                    
                                                                    }
                    |   op_add  id                                  {
                                                                        if(!isVarDefined($2.addr)){
                                                                            printf("ERROR : variable %s is not defined\n", $2.addr);
                                                                            exit(-1);
                                                                        }
                                                                        $$.addr = $2.addr;
                                                                    }                 
                    |	op_add	number								{ 
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s\n", $$.addr, $2.addr); 
                                                                    }
                    |   id                                          {
                                                                        if(!isVarDefined($1.addr)){
                                                                            printf("ERROR : variable %s is not defined\n", $1.addr);
                                                                            exit(-1);
                                                                        }
                                                                        $$.addr = $1.addr;
                                                                    }
                    |	number										{   
                                                                        $$.addr = next_var();
                                                                        printf("%s = %s\n", $$.addr, $1.addr); 
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