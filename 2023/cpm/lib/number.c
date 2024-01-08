#ifdef __STDC__
#include <stdlib.h>
#else
#include "stdio.h"
#endif

#include "number.h"

long min(a, b)
long a;
long b;
{
    if (a <= b) { return a; }
    return b;
}
