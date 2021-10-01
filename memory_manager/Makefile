a.out: solution.o membanks.o
		gcc solution.o membanks.o -o solution -O2 -ftrapv -fsanitize=undefined -Wall -Werror -Wformat-security -Wignored-qualifiers -Winit-self -Wswitch-default -Wfloat-equal -Wshadow -Wpointer-arith -Wtype-limits -Wempty-body -Wlogical-op -Wstrict-prototypes -Wold-style-declaration -Wold-style-definition -Wmissing-parameter-type -Wmissing-field-initializers -Wnested-externs -Wno-pointer-sign -Wcast-qual -Wwrite-strings -std=gnu11 -lm

membanks.o: membanks.c membanks.h
		gcc membanks.c -c

main.o: solution.c
		gcc solution.c -c

clean:
		rm solution.o membanks.o

cleanall:
		rm solution.o membanks.o solution