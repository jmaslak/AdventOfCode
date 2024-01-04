CCOPT=-I../lib
LINKOPT=-L../lib

3: 3.o ../lib/libutil.a ../lib/libtable.a
	gcc $(LINKOPT) -o 3 3.o -ltable -lutil

3.o: 3.c ../lib/error.h ../lib/table.h
	gcc $(CCOPT) -c 3.c

clean:
	rm -f 3 *.o
