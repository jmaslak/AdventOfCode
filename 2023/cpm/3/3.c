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
#include "table.h"

char check_neighbors();
unsigned long int part_a();
unsigned long int part_b();
unsigned long int gearval();
unsigned int get_start();
unsigned int get_end();
unsigned int get_num();

void main(argc, argv)
int argc;
char *argv[];
{
    struct table_struct * table;
    unsigned long int sum = 0;

    if (argc != 2) { error("Provide filename"); }
    table = read_table(argv[1]);

    sum = part_a(table);
    printf("Sum of part A: %ld\n", sum);
    sum = part_b(table);
    printf("Sum of part B: %ld\n", sum);

    free_table(table);
}

unsigned long int part_b(table)
struct table_struct * table;
{
    unsigned int num;
    unsigned int symbol;
    unsigned int row;
    unsigned int col;
    unsigned long int sum = 0;

    for (row=0; row < table->rows; row++) {
        for (col=0; col < table->rows; col++) {
            char c;
            c = get_xy(table, row, col);
            if (c == '*') {
                sum += gearval(table, row, col);
            }
        }
    }
    return sum;
}

unsigned long int part_a(table)
struct table_struct * table;
{
    unsigned int num;
    unsigned int symbol;
    unsigned int row;
    unsigned int col;
    unsigned long int sum = 0;

    for (row=0; row < table->rows; row++) {
        num = 0;
        symbol = 0;
        for (col=0; col < table->rows; col++) {
            char c;
            c = get_xy(table, row, col);
            if (isdigit(c)) {
                num = num * 10 + c - '0';
                if ((!symbol) && check_neighbors(table, row, col)) {
                    symbol = 1;
                }
            } else {
                if (num) {
                    if (symbol) {
                        sum += num;
                        symbol = 0;
                    }
                    num = 0;
                }
            }
        }
        if (num) {
            if (symbol) {
                sum += num;
                symbol = 0;
            }
            num = 0;
        }
    }

    return sum;
}

char check_neighbors(table, row, col)
struct table_struct * table;
unsigned int row;
unsigned int col;
{
    unsigned int minrow, mincol, maxrow, maxcol, i, j;

    mincol = col;
    maxcol = col;
    minrow = row;
    maxrow = row;

    if (col > 0) { mincol--; }
    if (row > 0) { minrow--; }
    if (col+1 < table->cols) { maxcol++; }
    if (row+1 < table->rows) { maxrow++; }

    for (i=minrow; i<=maxrow; i++) {
        for (j=mincol; j<=maxcol; j++) {
            char c;
            c = get_xy(table, i, j);
            if ((c != '.') && (!isdigit(c))) {
                return 1;
            }
        }
    }
    return 0;
}

unsigned long int gearval(table, row, col)
struct table_struct * table;
unsigned int row;
unsigned int col;
{
    unsigned int pos;
    int i, j;
    unsigned long num = 0;
    unsigned long ret = 1;
    char c;
    char flag = 0;

    /* Check above */
    if (row > 0) {
        /* Above left */
        i = -1;
        j = -1;
        if (col > 0) {
            c = get_xy(table, row-1, col-1);
            if (isdigit(c)) {
                i = get_start(table, row-1, col-1);
                j = get_end(table, row-1, col-1);
                ret = get_num(table, row-1, i, j);
                flag++;
            }
        }
        /* Above mid */
        if (i < 0) {
            c = get_xy(table, row-1, col);
            if (isdigit(c)) {
                i = get_start(table, row-1, col);
                j = get_end(table, row-1, col);
                ret = get_num(table, row-1, i, j);
                flag++;
            }
        }
        /* Above right */
        if ((j < (int) col) && (col+1 < table->cols)) {
            c = get_xy(table, row-1, col+1);
            if (isdigit(c)) {
                i = get_start(table, row-1, col+1);
                j = get_end(table, row-1, col+1);
                num = get_num(table, row-1, i, j);
                flag++;
                ret *= num;
            }
        }
    }

    /* Check this row */
    /* left */
    i = -1;
    j = -1;
    if (col > 0) {
        c = get_xy(table, row, col-1);
        if (isdigit(c)) {
            i = get_start(table, row, col-1);
            num = get_num(table, row, i, col-1);
            flag++;
            ret *= num;
        }
    }
    /* right */
    if (col+1 < table->cols) {
        c = get_xy(table, row, col+1);
        if (isdigit(c)) {
            j = get_end(table, row, col+1);
            num = get_num(table, row, col+1, j);
            flag++;
            ret *= num;
        }
    }

    /* Check below */
    if (row+1 < table->rows) {
        /* Below left */
        i = -1;
        j = -1;
        if (col > 0) {
            c = get_xy(table, row+1, col-1);
            if (isdigit(c)) {
                i = get_start(table, row+1, col-1);
                j = get_end(table, row+1, col-1);
                num = get_num(table, row+1, i, j);
                flag++;
                ret *= num;
            }
        }
        /* Below mid */
        if (i < 0) {
            c = get_xy(table, row+1, col);
            if (isdigit(c)) {
                i = get_start(table, row+1, col);
                j = get_end(table, row+1, col);
                num = get_num(table, row+1, i, j);
                flag++;
                ret *= num;
            }
        }
        /* Below right */
        if ((j < (int) col) && (col+1 < table->cols)) {
            c = get_xy(table, row+1, col+1);
            if (isdigit(c)) {
                i = get_start(table, row+1, col+1);
                j = get_end(table, row+1, col+1);
                num = get_num(table, row+1, i, j);
                flag++;
                ret *= num;
            }
        }
    }

    if (flag == 2) { return ret; }

    return 0;
}

unsigned int get_start(table, row, col)
struct table_struct * table;
unsigned int row, col;
{
    while (col > 0) {
        if (isdigit(get_xy(table, row, col-1))) {
            col--;
        } else {
            break;
        }
    }
    return col;
}

unsigned int get_end(table, row, col)
struct table_struct * table;
unsigned int row, col;
{
    while (col+1 < table->cols) {
        if (isdigit(get_xy(table, row, col+1))) {
            col++;
        } else {
            break;
        }
    }
    return col;
}

unsigned int get_num(table, row, colstart, colend)
struct table_struct * table;
unsigned int row, colstart, colend;
{
    unsigned int num = 0;
    while (colstart <= colend) {
        num = num * 10 + get_xy(table, row, colstart) - '0';
        colstart++;
    }
    return num;
}
