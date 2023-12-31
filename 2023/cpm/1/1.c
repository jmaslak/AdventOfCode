#ifdef __STDC__
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#else
#include "ctype.h"
#include "stdio.h"
#endif

char *nums[] = {
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine"
};

struct line {
    char * text;
    struct line * next;
};

struct line * read_lines();
void free_lines();
int is_text_num();

void main() {
    struct line * start;
    struct line * node;
    unsigned long sum_a = 0;
    unsigned long sum_b = 0;
    start = read_lines();
    node = start;

    while (node != NULL) {
        unsigned char * c;
        int first_a = -1;
        int first_b = -1;
        int last_a = -1;
        int last_b = -1;
        
        c = &(node->text[0]);
        while (*c != '\0') {
            if (isdigit(*c)) {
                last_a = *c - '0';
                last_b = last_a;
                if (first_a < 0) {
                    first_a = last_a;
                }
                if (first_b < 0) {
                    first_b = last_b;
                }
            }
            if (is_text_num(c) >= 0) {
                last_b = is_text_num(c);
                if (first_b < 0) {
                    first_b = last_b;
                }
            }
            c++;
        }

        sum_a += first_a * 10 + last_a;
        sum_b += first_b * 10 + last_b;
        first_a = -1;
        first_b = -1;
        last_a = -1;
        last_b = -1;

        node = node->next;
    }

    printf("Part 1A Sum: %lu\n", sum_a);
    printf("Part 1B Sum: %lu\n", sum_b);

    free_lines(start);
}

struct line * read_lines() {
    char chunk[128];
    struct line * start;
    struct line ** prev;

    prev = &start;
    while (fgets(chunk, sizeof(chunk), stdin) != NULL) {
        chunk[127] = '\0';
        *prev = malloc(sizeof(struct line));
        if (chunk[strlen(chunk)-1] == '\n') {
            chunk[strlen(chunk)-1] = '\0';
        }
        (*prev)->text = malloc(sizeof(char) * strlen(chunk) + 1);
        (*prev)->next = NULL;
        strcpy((*prev)->text, chunk);

        prev = &((*prev)->next);
    }

    return start;
}

void free_lines(start)
struct line * start;
{
    struct line * current;
    current = start;
    while (current != NULL) {
        struct line * next;
        next = current->next;
        free(current->text);
        free(current);
        current = next;
    }
}

int is_text_num(c)
char * c;
{
    int i;
    for (i=0; i<10; i++) {
        char *c1;
        char *c2;
        c1 = nums[i];
        c2 = c;
        while ((*c1 == '\0') || (*c1 == *c2)) {
            if (*c1 == '\0') { return i; }
            c1++;
            c2++;
        }
    }
    return -1;
}
