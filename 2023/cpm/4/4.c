#ifdef __STDC__
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#else
#include "ctype.h"
#include "stdio.h"
#include "strtok.h"
#endif

#include "error.h"
#include "malloc.h"

void count_numbers();
int a_process_card();
unsigned long b_process_card();

struct listele {
    unsigned long cnt;
    struct listele * next;
};

int main(argc, argv)
int argc;
char *argv[];
{
    FILE *f;
    char buffa[256];
    char buffb[256];
    unsigned long sum_a = 0;
    unsigned long sum_b = 0;
    struct listele * list = NULL;

    if (argc != 2) { error("Provide filename"); }

    f = fopen(argv[1], "r");
    if (f == NULL) { error("Can't open"); }

    while (fgets(buffa, 256, f) != NULL) {
        strcpy(buffb, buffa);
        sum_a += a_process_card(buffa);
        sum_b += b_process_card(buffb, &list);
    }

    printf("Part A point sum: %lu\n", sum_a);
    printf("Part B cards processed: %lu\n", sum_b);

    a_process_card(NULL);  /* Free memory */
    b_process_card(NULL);  /* Free memory */

    return 0;
}

int a_process_card(card)
char *card;
{
    static char nums = 0;
    static char drawn = 0;
    char * save = NULL;
    char flag = 0;
    static char * numbers;
    register int num = 0;
    int i;
    int ret = 1;
    char * tok;

    if (card == NULL) {
        /* Free memory */
        free(numbers);
        return 0;
    }

    if (nums == 0) {
        count_numbers(card, &nums, &drawn);
        numbers = safe_malloc(sizeof(char) * nums);
    }

    tok = strtok_r(card, ":", &save);
    if (tok == NULL) { error("Line empty"); }

    while (NULL != (tok = strtok_r(NULL, " \n", &save))) {
        if (strcmp(tok, "|") == 0) {
            flag = 1;
        } else if (!flag) {
            sscanf(tok, "%d", &i);
            numbers[num++] = i;
        } else {
            sscanf(tok, "%d", &i);
            for (num=0; num<nums; num++) {
                if (numbers[num] == i) {
                    ret = ret << 1;
                    break;
                }
            }
        }
    }
    return (ret >> 1);
}

unsigned long b_process_card(card, head)
char *card;
struct listele **head;
{
    static char nums = 0;
    static char drawn = 0;
    char * save = NULL;
    char flag = 0;
    static char * numbers;
    register int num = 0;
    int i;
    unsigned long ret = 1;
    int draw = 0;
    char * tok;

    if (card == NULL) {
        /* Free memory */
        free(numbers);
        return 0;
    }

    if (nums == 0) {
        count_numbers(card, &nums, &drawn);
        numbers = safe_malloc(sizeof(char) * nums);
    }

    tok = strtok_r(card, ":", &save);
    if (tok == NULL) { error("Line empty"); }

    while (NULL != (tok = strtok_r(NULL, " \n", &save))) {
        if (strcmp(tok, "|") == 0) {
            flag = 1;
        } else if (!flag) {
            sscanf(tok, "%d", &i);
            numbers[num++] = i;
        } else {
            sscanf(tok, "%d", &i);
            for (num=0; num<nums; num++) {
                if (numbers[num] == i) {
                    draw++;
                    break;
                }
            }
        }
    }

    if ((*head) != NULL) {
        struct listele *newhead;
        newhead = (*head)->next;
        ret = 1 + (*head)->cnt;
        free(*head);
        *head = newhead;
    }

    while (draw--) {
        if (*head == NULL) {
            *head = (struct listele *) safe_malloc(sizeof(struct listele));
            (*head)->cnt = 0;
            (*head)->next = NULL;
        }
        (*head)->cnt += ret;
        head = &((*head)->next);
    }

    return ret;
}

void count_numbers(card, nums, drawn)
char * card;
char * nums;
char * drawn;
{
    char * save = NULL;
    char * tok;
    char * copy;
    char flag = 0;

    copy = safe_malloc(strlen(card)+1);
    strcpy(copy, card);

    *nums = 0;
    *drawn = 0;

    tok = strtok_r(copy, ":", &save);
    if (tok == NULL) { error("Line empty"); }

    while (NULL != (tok = strtok_r(NULL, " \n", &save))) {
        if (strcmp(tok, "|") == 0) {
            flag = 1;
        } else if (!flag) {
            (*nums)++;
        } else {
            (*drawn)++;
        }
    }

    free(copy);
}
