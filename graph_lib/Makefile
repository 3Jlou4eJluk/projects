a.out: graph.o main.o  graph_algo.o
	gcc graph.o main.o graph_algo.o -g -lm
graph.o: graph.c graph.h 
	gcc graph.c -c -g
main.o: main.c
	gcc main.c -c -g
graph_algo.o: graph_algo.c graph_algo.h
	gcc graph_algo.c -c -g
clean:
	rm main.o graph.o a.out graph_algo.o