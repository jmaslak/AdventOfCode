#ifdef __STDC__
#include <stdio.h>
#include <stdlib.h>
#else
#include "stdio.h"
#endif

#include "error.h"

void error(str)
char * str;
{
    printf("%s", str);
    printf("\n");
    exit(1);
}
