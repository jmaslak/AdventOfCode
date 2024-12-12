#include <string.h>

#define DIE(msg) fprintf(stderr, "Error at line %d in file %s: %s\n", __LINE__, __FILE__, msg); exit(1);

void chomp(char * str);

void chomp(char * str) {
    int len = strlen(str);
    if (str[len-1] == '\n') {
        str[len-1] = '\0';
    }
}