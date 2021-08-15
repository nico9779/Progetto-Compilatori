#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H


#ifndef _STDIO_H
#include <stdio.h>
#endif


typedef struct variable
{
	char* id;
	char* type;
	char* address;
}variable;


typedef struct symbol_table
{
	variable* data;
	int capacity;
	int size;
}symbol_table;


void allocateSymbolTable(symbol_table* table, int start_capacity);

void destroySymbolTable(symbol_table* table);

void resizeSymbolTable(symbol_table* table, int new_capacity);



variable* findVariableInSymbolTable(symbol_table* table, char* id);

int addVariableToSymbolTable(symbol_table* table, char* id, char* type, char* address);

void printVariable(FILE* stream, variable* var);

void printSymbolTable(FILE* stream, symbol_table* table);


# endif