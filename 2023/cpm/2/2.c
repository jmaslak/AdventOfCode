#ifdef __STDC__
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#else
#include "ctype.h"
#include "stdio.h"
#endif

struct rgb_colors {
    unsigned char r;
    unsigned char g;
    unsigned char b;
};

void main() {
    char chunk[256];
    unsigned int sum_a = 0;
    unsigned int sum_b = 0;

    while (fgets(chunk, sizeof(chunk), stdin) != NULL) {
        unsigned int id = 0;
        struct rgb_colors rgb;
        char * c;
        chunk[255] = '\0';

        rgb.r = 0;
        rgb.g = 0;
        rgb.b = 0;

        c = &(chunk[0]);
        while ((*c != ':') && (*c != '\0')) {
            if (isdigit(*c)) {
                id = id * 10 + *c - '0';
            }
            c++;
        }

        while (*c != '\0') {
            unsigned char val = 0;
            c++;
            while ((*c != ';') && (*c != '\0')) {
                if (isdigit(*c)) {
                    val = val * 10 + *c - '0';
                } else if (*c == 'r') {
                    if (rgb.r < val) {
                        rgb.r = val;
                    }
                    val = 0;
                } else if (*c == 'g') {
                    if (rgb.g < val) {
                        rgb.g = val;
                    }
                    val = 0;
                } else if (*c == 'b') {
                    if (rgb.b < val) {
                        rgb.b = val;
                    }
                    val = 0;
                }
                c++;
            }
        }

        if ((rgb.r <= 12) && (rgb.g <= 13) && (rgb.b <= 14)) {
            sum_a += id;
        }
        sum_b += rgb.r * rgb.b * rgb.g;
    }

    printf("Sum part A: %u\n", sum_a);
    printf("Sum part B: %u\n", sum_b);
}
