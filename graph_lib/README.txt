In the graph.c module, I implemented the functions:
struct Graph* graph_init(void); - initialization of the graph
int graph_add_edge(struct Graph *graph, int start, int end, double weight); - adding an edge
int graph_del_edge(struct Graph* graph, int start, int end); - removing an edge
void print_graph(struct Graph* graph); - print count
int graph_add_vertex(struct Graph *graph, int vert); - added tops
int graph_del_vertex(struct Graph *graph, int vert); - removal of vertices
int graph_check_vertex(struct Graph * graph, int vertex); - check the presence of peaks
int graph_search_edge(struct Graph * graph, int start, int end, int reload_flag); - check the presence of edges
void graph_kill(struct Graph * graph); - deinitialization count

In a separate module(graph_algo.h) implemented
the struct Graph* dijkstra function(struct Graph * graph, int start, int end);
It looks for the shortest path from the vertex start to the vertex end and returns a graph containing this path. 
(Returns in the graph all the shortest paths that were calculated in the process.)

And now a little bit about how it is stored here, perhaps it is not quite clear in the comments to the code.

The vid array contains the vertex numbers specified by the user and the "service numbers", which represent the index of the vert array.
At the i-th place, in the vert array, the index is stored in the adj1 array of the end of the edge originating from the vertex with the 
service number i. The adj2 array stores the index in the adj1 array of the end of the next edge, also coming from vertex i, and so on until 
all edges coming from vertex i are listed. If there are no edges from vertex i, then the value 0 is in the vert array, in the i-th place. 
Thus, if there is only one edge, then the adj2[vert[i]] array will have 0. The source array stores the service number of the beginning of 
each edge, this is necessary for the fast operation of the vertex removal function (and not only). The wght array stores the weights of all 
edges. As I think, using this implementation, I managed to reduce the memory usage for storing the graph, compared to the adjacency matrix.
