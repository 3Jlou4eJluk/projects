CFLAGS = -c -g

solution: main.o tokens.o descent.o run.o
	gcc main.o tokens.o descent.o run.o -g -o solution -lm -Werror
main.o: main.c
	gcc main.c $(CFLAGS)
tokens.o: tokens.c tokens.h
	gcc tokens.c $(CFLAGS)
descent.o: descent.c descent.h
	gcc descent.c $(CFLAGS)
run.o: run.c run.h
	gcc run.c $(CFLAGS)
clean:
	rm tokens.o main.o descent.o run.o
cleanall:
	rm tokens.o main.o descent.o run.o solution