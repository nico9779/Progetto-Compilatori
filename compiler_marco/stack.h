#ifndef _STACK_H
#define _STACK_H


// Define the stack only if the data type is also defined.
#ifdef STACK_TYPE

typedef struct stack
{
	STACK_TYPE* data;
	int capacity;
	int size;
}stack;


extern void destroyStackElement(STACK_TYPE* ptr);


void allocateStack(stack* ptr, int start_capacity);
void destroyStack(stack* ptr);
void resizeStack(stack* ptr, int new_capacity);

#endif

#endif