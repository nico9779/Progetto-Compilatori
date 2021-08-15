#include "symbol_table.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void allocateSymbolTable(symbol_table* table, int start_capacity)
{
	// Check if the input parameter is valid.
	if (!table)
		return;

	// Can't allocate a symbol table with a negative or zero capacity.
	if (start_capacity < 1)
	{
		table->data = NULL;
		table->capacity = 0;
		table->size = 0;

		return;
	}


	// Allocate the buffer for the new symbol table.
	variable* data = malloc(sizeof(variable) * start_capacity);
	if (!data)
	{
		table->data = NULL;
		table->capacity = 0;
		table->size = 0;
	}
	else
	{
		// Clear the symbol table.
		memset(data, 0, sizeof(variable) * start_capacity);

		table->data = data;
		table->capacity = start_capacity;
		table->size = 0;
	}
}


void destroySymbolTable(symbol_table* table)
{
	// Check if the input parameter is valid.
	if (!table)
		return;

	// Deallocate the buffer of the table and all of its content.
	if (table->data)
	{
		for (int i = 0; i < table->size; i++)
		{
			if (table->data[i].id)
			{
				free(table->data[i].id);
				table->data[i].id = NULL;
			}

			if (table->data[i].type)
			{
				free(table->data[i].type);
				table->data[i].type = NULL;
			}

			if (table->data[i].address)
			{
				free(table->data[i].address);
				table->data[i].address = NULL;
			}
		}


		free(table->data);
		table->data = NULL;
	}

	table->capacity = 0;
	table->size = 0;
}


void resizeSymbolTable(symbol_table* table, int new_capacity)
{
	// Check if the input parameters are valid.
	if (!table)
		return;
	
	if ((new_capacity < 1) || (!table->data))
	{
		table->data = NULL;
		table->capacity = 0;
		table->size = 0;

		return;
	}


	// Allocate the buffer for the new symbol table.
	variable* data = malloc(sizeof(variable) * new_capacity);
	if (!data)
	{
		table->data = NULL;
		table->capacity = 0;
		table->size = 0;

		return;
	}


	// Clear the new symbol table.
	memset(data, 0, sizeof(variable) * new_capacity);

	// Copy the data from the old table.
	const int new_size = new_capacity < table->capacity ? new_capacity: table->capacity;
	for (int i = 0; i < new_size; i++)
	{
		// Note: copy only the pointers, not the data itself!
		data[i].id = table->data[i].id;
		data[i].type = table->data[i].type;
		data[i].address = table->data[i].address;
	}

	// Destroy the old symbol table.
	free(table->data);
	table->data = NULL;
	table->capacity = 0;
	table->size = 0;
	// Do not use this, or it will cancel also the data of the new table (Note: above, it copies the pointers not the data itself!).
	//destroySymbolTable(&table);


	// Return the new symbol table.
	table->data = data;
	table->capacity = new_capacity;
	table->size = new_size;
}


variable* findVariableInSymbolTable(symbol_table* table, char* id)
{
	// Check if the input parameters are valid.
	if ((!table) || (!table->data) || (!id))
		return NULL;


	// Perform a linear search for the id in the entire symbol table.
	for (int i = 0; i < table->size; i++)
	{
		if (strcmp(id, table->data[i].id) == 0)
			return table->data + i;
	}

	// id not found, so return null.
	return NULL;
}


int addVariableToSymbolTable(symbol_table* table, char* id, char* type, char* address)
{
	// Check if the input parameters are valid.
	if ((!table) || (!table->data) || (!id) || (!type))
		return -1;


	// Check if the id is already in the symbol table.
	variable* ptr = findVariableInSymbolTable(table, id);
	if (ptr)
	{
		// Check if the associated type matches or not.
		if (strcmp(type, ptr->type) == 0)
			return 1;
		else
			return -2;
	}
	else
	{
		// Resize the symbol table if needed.
		if (table->size == table->capacity)
		{
			resizeSymbolTable(table, table->capacity * 2);

			if (!table->data)
				return -3;
		}


		// Add the new id into the symbol table.
		table->data[table->size].id = strdup(id);
		if (!table->data[table->size].id)
			return -4;

		table->data[table->size].type = strdup(type);
		if (!table->data[table->size].type)
			return -4;

		table->data[table->size].address = strdup(address);
		if (!table->data[table->size].address)
			return -4;
		
		table->size++;


		return 0;
	}
}


void printVariable(FILE* stream, variable* var)
{
	fprintf(stream, "ID: %s   Type: %s   Address: %s\n", var->id, var->type, var->address);
}


void printSymbolTable(FILE* stream, symbol_table* table)
{
	// Check if the input parameters are valid.
	if ((!table) || (!table->data))
		return;
	
	
	for (int i = 0; i < table->size; i++)
		printVariable(stream, &table->data[i]);
}