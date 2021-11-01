#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "graph.h"
#include "graph_algo.h"

int main(void) {
    struct Graph* mygraph;
    mygraph = graph_init();
    print_graph(mygraph);
    graph_add_edge(mygraph, 1, 2, 7);
    graph_add_edge(mygraph, 1, 3, 9);
    graph_add_edge(mygraph, 1, 6, 14);
    graph_add_edge(mygraph, 2, 4, 15);
    graph_add_edge(mygraph, 2, 3, 10);
    graph_add_edge(mygraph, 3, 4, 11);
    graph_add_edge(mygraph, 3, 6, 2);
    graph_add_edge(mygraph, 6, 5, 9);
    graph_add_edge(mygraph, 4, 5, 6);
    print_graph(mygraph);
    struct Graph *wae = dijkstra(mygraph, 1, 5);
    printf("\nWe kno da wae\n");
    print_graph(wae);
    graph_kill(wae);
    graph_kill(mygraph);
}