%{

#include <stdio.h>
#include <ctype.h>
#include <string.h>

int yylex();
void yyerror(char* str);

int counter = 1;

char* next_var(){
    static char s[5];
    sprintf(s, "t%d", counter);
    counter++;
    return s;
}

%}

%union{
    struct address {
        int value;
        char* addr;
    } address; 
}

%token <address> NUMBER

%token <address> KW_FALSE
%token <address> KW_TRUE

%token <address> OP_ADD
%token <address> OP_SUB
%token <address> OP_MUL
%token <address> OP_DIV

%token <address> OP_LT
%token <address> OP_LE
%token <address> OP_EQ
%token <address> OP_NEQ
%token <address> OP_GT
%token <address> OP_GE

%token <address> OP_AND
%token <address> OP_OR
%token <address> OP_XOR
%token <address> OP_NOT

%token <address> BR_ROUND_OPEN
%token <address> BR_ROUND_CLOSE

%token <address> SEMICOLON

%type <address> bool_expr
%type <address> int_expr

%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right OP_UMINUS


%left OP_OR OP_XOR
%left OP_AND
%right OP_NOT
%nonassoc OP_LT OP_LE OP_EQ OP_NEQ OP_GT OP_GE

%%

line			:	line bool_expr SEMICOLON					{ }
				|	line int_expr SEMICOLON						{ }
				|
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
																	$$.addr = $2.addr;
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

				|	BR_ROUND_OPEN int_expr BR_ROUND_CLOSE		{ $$.addr = $2.addr; }

				|	OP_SUB int_expr %prec OP_UMINUS				{ 
                                                                    char* temp = next_var();
                                                                    printf("%s = -%s\n", temp, $2.addr);
                                                                    $$.addr = strdup(temp); 
                                                                }

				|	OP_ADD	NUMBER								{ 
                                                                    char* temp = next_var();
                                                                    printf("%s = %d\n", temp, yylval.address.value);
                                                                    $$.addr = strdup(temp); 
                                                                }
				|	NUMBER										{   
                                                                    char* temp = next_var();
                                                                    printf("%s = %d\n", temp, yylval.address.value);
                                                                    $$.addr = strdup(temp); 
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