To compile on Z80 using Aztec C:

    cz error
    cz malloc
    cz strtok
    cz table
    as error
    as malloc
    as number
    as strtok
    as table
    libutil -o util.lib strtok.o malloc.o number.o erro.o
    libutil -o table.lib table.o

