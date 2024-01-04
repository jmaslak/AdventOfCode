#ifdef __STDC__
#include <stdlib.h>
#else
#include "stdio.h"
#endif

#include "error.h"
#include "malloc.h"

char * safe_malloc(size)
unsigned int size;
{
    char * p;
    p = malloc(size);
    if (p == NULL) { error("No memory"); }
    return p;
}
