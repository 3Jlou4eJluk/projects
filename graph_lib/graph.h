/*
Implementation of an oriented weighted pseudomultigraph
using a modified adjacency list
*/

enum {
	// initial size of all dynamic arrays
	START_VERT_QUANTITY = 10,

	// the size will increase by this number of times
	// array, if there is not enough memory
	DYNAMIC_COEF = 2
};

#define INTFORMAT "%5d"
#define FLOFORMAT " %0.2f"

/*
We will use the adjacency matrix.
If no arcs come out of the vertex with the number i, then
vert[i] = 0. If at least one arc exits a
vertex, then adj1[vert[i]] stores the end of this
arc, and adj1[adj2[vert[i]]] stores the end
of the next edge leaving this vertex, etc.
The weight of the arc is stored in wght[vert[i]].

actn - index of the last vertex
vert_size - the current size of the dynamic array of vertices
edge_size - the current size of the dynamic array of edges

UPD:
Now the vertex numbers
specified by the user are stored in the vid array (so as not to be bound to
the array index). And each id corresponds
to the vertex number in the array vert = i

UPD(31.10.21):
Now we will also store the source array. This will
save time when deleting edges entering the vertex.
*/
struct Graph {
    int vert_size;
    int edge_size;
    int actn;
    int *vert;
    int *vid;
    int *adj1;
    int *adj2;
    int *source;
    double *wght;
};

struct Graph* graph_init(void);
int graph_add_edge(struct Graph *graph, int start, int end, double weight);
int graph_del_edge(struct Graph* graph, int start, int end);
void print_graph(struct Graph* graph);
int graph_add_vertex(struct Graph *graph, int vert);
int graph_del_vertex(struct Graph *graph, int vert);
int graph_check_vertex(struct Graph * graph, int vertex);
int graph_search_edge(struct Graph * graph, int start, int end, int reload_flag);
void graph_kill(struct Graph * graph);