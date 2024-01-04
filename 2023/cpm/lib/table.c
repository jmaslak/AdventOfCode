#ifdef __STDC__
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#else
#include "ctype.h"
#include "stdio.h"

#define SEEK_SET (0)
#define SEEK_CUR (1)
#define SEEK_END (2)

#endif

#include "error.h"
#include "malloc.h"
#include "table.h"

void free_table(table)
struct table_struct * table;
{
    free(table->data);
    free(table);
}

struct table_struct * read_table(filename)
char * filename;
{
    FILE *f;
    char * buff;
    unsigned int rows;
    unsigned int cols;
    unsigned int size;
    int ret;
    char hascr = 0;
    struct table_struct * table;
    unsigned int tpos;
    char * junk[2];

    table = (struct table_struct *) safe_malloc(sizeof(struct table_struct));

    buff = safe_malloc(256*sizeof(char));
    f = fopen(filename, "r");
    if (f == NULL) { error("Can't open file"); }

    ret = fread(buff, sizeof(char), 256, f);
    if (ret == 0) { error("Can't read file"); }

    for (cols=0; cols<ret; cols++) {
        if (buff[cols] == '\r') { hascr = 1; }
        if (buff[cols] == '\n') { break; }
    }
    if (hascr) { cols--; }

    fseek(f, 0L, SEEK_END);
    size = ftell(f);
    fclose(f);
    rows = size / (cols+1+hascr);

    table->rows = rows;
    table->cols = cols;
    table->data = safe_malloc(rows * cols);

    f = fopen(filename, "r");
    if (f == NULL) { error("Can't open file"); }

    for (tpos=0; tpos<rows; tpos++) {
        ret = fread(table->data + tpos*cols, sizeof(char), cols, f);
        if (ret != cols) { error("read failed"); }

        /* Skip remaining junk */
        fread(junk, sizeof(char), 1+hascr, f);
    }

    fclose(f);
    free(buff);

    return table;
}

void print_table(table)
struct table_struct * table;
{
    int row;
    int col;

    for (row=0; row<table->rows; row++) {
        for (col=0; col<table->cols; col++) {
            printf("%c", table->data[row*table->cols + col]);
        }
        printf("\n");
    }
    printf("\n");
}

char get_xy(table, row, col)
struct table_struct * table;
unsigned int row;
unsigned int col;
{
    return table->data[row * table->cols + col];
}
