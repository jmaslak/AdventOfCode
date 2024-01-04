all: libtable.a libutil.a

libtable.a: table.o
	ar rcs libtable.a table.o

libutil.a: error.o malloc.o strtok.o
	ar rcs libutil.a error.o malloc.o strtok.o

table.o: table.c table.h

error.o: error.c error.h

malloc.o: malloc.c malloc.h

strtok.o: strtok.c strtok.h

clean:
	rm -f *.o *.a
