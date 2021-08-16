#include <stdlib.h>
#include "stack.h"


#ifdef STACK_TYPE


void allocateStack(stack* ptr, int start_capacity)
{
	// Check if the input parameter is valid.
	if (!ptr)
		return;

	// Can't allocate a stack with negative or zero capacity.
	if (start_capacity < 1)
	{
		ptr->data = NULL;
		ptr->capacity = 0;
		ptr->size = 0;

		return;
	}


	// Allocate the buffer for the new stack.
	STACK_TYPE* data = (STACK_TYPE*)malloc(sizeof(STACK_TYPE) * start_capacity);
	if (!data)
	{
		ptr->data = NULL;
		ptr->capacity = 0;
		ptr->size = 0;
	}
	else
	{
		// Clear the symbol table.
		memset(data, 0, sizeof(STACK_TYPE) * start_capacity);

		ptr->data = data;
		ptr->capacity = start_capacity;
		ptr->size = 0;
	}
}


void destroyStack(stack* ptr)
{
	// Check if the input parameter is valid.
	if (!ptr)
		return;

	// Deallocate the buffer of the stack and all of its content.
	if (ptr->data)
	{
		for (int i = 0; i < ptr->size; i++)
			destroyStackElement(ptr->data + i);
		
		free(ptr->data);
		ptr->data = NULL;
	}

	ptr->capacity = 0;
	ptr->size = 0;
}


void resizeStack(stack* ptr, int new_capacity)
{
	// Check if the input parameters are valid.
	if (!ptr)
		return;

	if ((new_capacity < 1) || (!ptr->data))
	{
		ptr->data = NULL;
		ptr->capacity = 0;
		ptr->size = 0;

		return;
	}


	// Allocate the buffer for the new stack.
	STACK_TYPE* data = (STACK_TYPE*)malloc(sizeof(STACK_TYPE) * new_capacity);
	if (!data)
	{
		ptr->data = NULL;
		ptr->capacity = 0;
		ptr->size = 0;

		return;
	}

	
	// Clear the buffer of the new stack.
	memset(data, 0, sizeof(STACK_TYPE) * new_capacity);

	// Copy the data from the old stack.
	const int new_size = new_capacity < ptr->size ? new_capacity: ptr->size;
	memcpy(data, ptr->data, sizeof(STACK_TYPE) * new_size);


	// Destroy the old stack.
	free(ptr->data);

	
	// Return the new stack.
	ptr->data = data;
	ptr->capacity = new_capacity;
	ptr->size = new_size;
}


#endif