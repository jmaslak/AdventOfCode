#include <stdio.h>
#include <stdlib.h>
#include "aoc.h"

#define MALLOC_ERR "Could not allocate memory"

#define BUFF_SIZE   8192
#define STATE_FREE  1
#define STATE_FILE  2
#define VAL_FREE    -1
#define METHOD_BYTE 1
#define METHOD_FILE 2

char * read_input();
void print_storage(int * storage, int len);
int * copy_storage(int * storage, int len);
int get_first_free(int * working, int len, int size);
int * defrag(int * src, int len, int method);
long int checksum(int * working, int len);

int main(void) {
    char * input = read_input();
    chomp(input);

    // Create initial view of data
    // This is a dumb method of allocation, but it'll work.
    int maxsize = strlen(input) * 9 + 1;  // Max possible length;
    int * storage = malloc(sizeof(int) * maxsize);
    if (storage == NULL) { DIE(MALLOC_ERR) }

    int state = STATE_FILE;
    int fileno = 0;
    int pos = 0;
    for (int i=0; i<strlen(input); i++) {
        int val = input[i] - '0';
        if (state == STATE_FILE) {
            for (int j=0; j<val; j++) {
                storage[pos++] = fileno;
            }
            fileno++;
            state = STATE_FREE;
        } else {
            for (int j=0; j<val; j++) {
                storage[pos++] = VAL_FREE;
            }
            state = STATE_FILE;
        }
    }
    int len = pos;
    free(input);

    int * working = defrag(storage, len, METHOD_BYTE);
    printf("Part 1: %ld\n", checksum(working, len));
    free(working);

    working = defrag(storage, len, METHOD_FILE);
    printf("Part 2: %ld\n", checksum(working, len));
    free(working);
    free(storage);

    return 0;
}

char * read_input() {
    char * output = malloc(sizeof(char) * BUFF_SIZE);
    if (output == NULL) { DIE(MALLOC_ERR) }

    int offset = 0;
    int size = BUFF_SIZE;
    int bytes;

    while ((bytes = fread(output+offset, sizeof(char), BUFF_SIZE, stdin))) {
        size += bytes;
        if (bytes == BUFF_SIZE) {
            offset += BUFF_SIZE;
            output = realloc(output, size);
            if (output == NULL) { DIE(MALLOC_ERR) }
        }
    }
    output[offset+size] = '\0';
    return output;
}

void print_storage(int * storage, int len) {
    for (int i=0; i<len; i++) {
        if (storage[i] == VAL_FREE) {
            printf(".");
        } else {
            printf("%d", storage[i]);
        }
        printf(" ");
    }
    printf("\n");
}

int * copy_storage(int * storage, int len) {
    int * new = malloc(sizeof(int) * len);
    if (new == NULL) { DIE(MALLOC_ERR) }
    memcpy(new, storage, sizeof(int) * len);
    return new;
}

int * defrag(int * src, int len, int method) {
    int * working = copy_storage(src, len);

    int pos = len - 1;

    while (1) {
        int free;
        if (pos < 0) { break; }
        if (working[pos] == VAL_FREE) {
            pos--;
            continue;
        }

        int data_size = 1;
        while ((pos-1 >= 0) && (working[pos-1] == working[pos])) {
            pos--;
            data_size++;
        }

        int free_size;
        if (method == METHOD_BYTE) {
            free = get_first_free(working, pos, 1);
            free_size = 1;
        } else {
            free = get_first_free(working, pos, data_size);
            free_size = data_size;
        }

        if (free > pos) { break; }

        if (free == -1) {
            pos--;
            continue;
        }

        pos = pos+data_size-1;
        for (int i=pos; i>=pos-free_size+1; i--) {
            working[free++] = working[i];
            working[i] = VAL_FREE;
        }
        pos = pos-free_size+1;
    }

    return working;
}

int get_first_free(int * working, int len, int size) {
    int free = -1;
    for (int i=0; i<len; i++) {
        if (free == -1) {
            if (working[i] == VAL_FREE) {
                free = i;
                if (size == 1) {
                    return free;
                }
            }
        } else {
            if (working[i] != VAL_FREE) {
                free = -1;
            } else {
                if (1 + i - free >= size) {
                    return free;
                }
            }
        }
    }
    return -1;
}

long int checksum(int * working, int len) {
    long int sum = 0;
    for (int i=0; i<len; i++) {
        if (working[i] != VAL_FREE) {
            sum += i * working[i];
        }
    }
    return sum;
}