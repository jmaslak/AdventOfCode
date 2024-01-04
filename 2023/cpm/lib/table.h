#ifndef __TABLE__
#define __TABLE__ (1)

struct table_struct {
    unsigned int rows;
    unsigned int cols;
    char * data;
};

extern void free_table();
extern struct table_struct * read_table();
extern void print_table();
extern char get_xy();

#endif
