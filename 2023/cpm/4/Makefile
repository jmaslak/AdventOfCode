CCOPT=-I../lib -Wall
LINKOPT=-L../lib

4: 4.o ../lib/libutil.a ../lib/libtable.a
	gcc $(LINKOPT) -o 4 4.o -lutil

4.o: 4.c ../lib/error.h ../lib/malloc.h ../lib/strtok.h
	gcc $(CCOPT) -c 4.c

clean:
	rm -f 4 *.o
