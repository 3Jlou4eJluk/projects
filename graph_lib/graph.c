#include <stdio.h>
#include <stdlib.h>
#include "graph.h"

/*
The graph_init(void) function returns a reference to
a Graph type structure if memory allocation was successful,
otherwise it returns NULL.

UPD(31.10.21):
Vertices cannot have an internal id = 0. This is done to
correctly search for edges in cycles of the form: while(adj1[i]!= 0)
*/
struct Graph* 
graph_init(void) {
    struct Graph* res;
    res = malloc(sizeof(struct Graph));

    if (res == NULL) {
        printf("\ngraph_init: OUT OF MEMORY\n");
        exit(1);
    }

    res -> actn = 1;
    res -> vert_size = START_VERT_QUANTITY;
    res -> edge_size = START_VERT_QUANTITY;

    res -> vert = calloc(START_VERT_QUANTITY, sizeof(int));
    res -> vid = calloc(START_VERT_QUANTITY, sizeof(int));
    res -> adj1 = calloc(START_VERT_QUANTITY, sizeof(int));
    res -> adj2 = calloc(START_VERT_QUANTITY, sizeof(int));
    res -> source = calloc(START_VERT_QUANTITY, sizeof(int));
    res -> wght = NULL;

    if ((res == NULL) || (res -> vert == NULL) || 
        (res -> vid == NULL) || (res -> adj1 == NULL) || 
        (res -> adj2 == NULL) || (res -> source == NULL)) {
        printf("\ngraph_init: OUT OF MEMORY\n");
        exit(1);
    }

    res -> wght = calloc(START_VERT_QUANTITY, sizeof(double));
    if (res -> wght == NULL) {
        printf("\ngraph_init: OUT OF MEMORY\n");
        exit(1);
    }

    for (int i = 0; i < START_VERT_QUANTITY; i++) {
        res -> vert[i] = 0;
        res -> vid[i] = 0;
        res -> adj1[i] = 0;
        res -> adj2[i] = 0;
        res -> wght[i] = 0;
        res -> source[i] = 0;
    }

    return res;
}


/*
If the vertex already exists, the function prints an error
and returns the number of this element in the array. 
If the vertex does not exist, it adds
it and returns the vertex number in the array
*/

int graph_add_vertex(struct Graph *graph, int vert) {
    int* tmp_int_p = NULL;
    int tmp_i = 0;
    int free_place_found_flag = 0;
    int res = 0;
    for (int i = 1; i < graph -> actn; i++) {
        if (graph -> vid[i] == vert) {
            printf("graph_add_vertex: WARNING, vertex already exists");
            return i;
        }
        if ((graph -> vid[i] == 0) && !free_place_found_flag) {
            tmp_i = i;
            free_place_found_flag = 1;
        }
    }
    if (free_place_found_flag) {
        graph -> vid[tmp_i] = vert;
        res = tmp_i;
    } else {
        if (graph -> actn == graph -> vert_size) {

            graph -> vert_size *= DYNAMIC_COEF;
            tmp_int_p = realloc(graph -> vert, 
                (graph -> vert_size) * sizeof(int));
            if (tmp_int_p == NULL) {
                printf("\ngraph_add_vertex: OUT OF MEMORY\n");
                exit(1);
            }
            graph -> vert = tmp_int_p;

            tmp_int_p = realloc(graph -> vid, 
                (graph -> vert_size) * sizeof(int));
            if (tmp_int_p == NULL) {
                printf("\ngraph_add_vertex: OUT OF MEMORY\n");
                exit(1);
            }
            graph -> vid = tmp_int_p;
        }
        res = graph -> actn;
        graph -> vid[graph -> actn] = vert;
        graph -> actn++;
    }
    return res;
}

int graph_del_vertex(struct Graph *graph, int vert) {
    int vert_found_flag = 0;
    int verti = 0;
    int tmp1 = 0;
    int tmp2 = 0;
    int cur_i = 1;
    for (int i = 1; (i < graph -> actn) && !vert_found_flag; i++) {
        if (graph -> vid[i] == vert) {
            vert_found_flag = 1;
            verti = i;
        }
    }

    if (verti == 0) {
        printf("\ngraph_del_vertex: WARNING, vertex not found\n");
    }

    tmp1 = graph -> vert[verti];
    graph -> vert[verti] = 0;
    
    // removing all outgoing edges
    while (tmp1 != 0) {
        tmp2 = tmp1;
        tmp1 = graph -> adj2[tmp1];
        graph -> adj1[tmp2] = 0;
        graph -> adj2[tmp2] = 0;
        graph -> wght[tmp2] = 0;
        graph -> source[tmp2] = 0;
    }

    // now we need to delete all incoming edges
    while ((cur_i < graph -> edge_size)) {
        if (graph -> adj1[cur_i] == verti) {
            graph_del_edge(graph, graph -> vid[graph -> source[cur_i]], vert);
        }
        cur_i++;
    }
    if (verti == graph -> actn - 1) {
        graph -> actn--;
    }
    graph -> vid[verti] = 0;
    return 0;
}


/*
The function adds an edge to the graph graph: start -> end.
*/
int graph_add_edge(struct Graph *graph, int start, int end, double weight) {

    // first we need to check if we already have such an edge and vertex
    int start_i = -1, end_i = -1;
    int* tmp_int_p;
    double* tmp_double_p;
    int tmp_i = 0;
    int tmp_i1 = 1;

    for (int i = 1; i < graph -> actn; i++) {
        if (graph -> vid[i] == start) {
            start_i = i;
        }
        if (graph -> vid[i] == end) {
            end_i = i;
        }
        if ((start_i != -1) && (end_i != -1)) {
            break;
        }
    }

    if (start_i == -1) {
        // so there is no vertex, we create a vertex
        start_i = graph_add_vertex(graph, start);
    }

    if (end_i == -1) {
        // so there is no vertex, we create a vertex
        end_i = graph_add_vertex(graph, end);
    }
    
    tmp_i = start_i;

    tmp_i1 = 1;
    while ((tmp_i1 < graph -> edge_size) && 
        (graph -> adj1[tmp_i1] != 0)) {
        tmp_i1++;
    }
    if (tmp_i1 == graph -> edge_size) {

        // if you got here, then the edge was not found,
        // at the same time there is not enough space to add a new edge
        // it is necessary to expand

        graph -> edge_size *= DYNAMIC_COEF;
        tmp_int_p = realloc(graph -> adj1, 
            sizeof(int) * graph -> edge_size);
        if (tmp_int_p == NULL) {
            printf("\ngraph_add_edge: OUT OF MEMORY\n");
            exit(1);
        }
        graph -> adj1 = tmp_int_p;

        tmp_int_p = realloc(graph -> adj2,
        sizeof(int) * graph -> edge_size);
        if (tmp_int_p == NULL) {
            printf("\ngraph_add_edge: OUT OF MEMORY\n");
            exit(1);
        }
        graph -> adj2 = tmp_int_p;

        tmp_int_p = realloc(graph -> source,
        sizeof(int) * graph -> edge_size);
        if (tmp_int_p == NULL) {
            printf("\ngraph_add_edge: OUT OF MEMORY\n");
            exit(1);
        }
        graph -> source = tmp_int_p;

        tmp_double_p = realloc(graph -> wght,
        sizeof(double) * graph -> edge_size);
        if (tmp_double_p == NULL) {
            printf("\ngraph_add_edge: OUT OF MEMORY\n");
            exit(1);
        }
        graph -> wght = tmp_double_p;
    }
    if (graph -> vert[tmp_i] == 0) {
        // so this is the first edge
        graph -> vert[tmp_i] = tmp_i1;
        graph -> adj1[tmp_i1] = end_i;
        graph -> wght[tmp_i1] = weight;
        graph -> source[tmp_i1] = start_i;
    } else {
        // so, the edge is not the first
        tmp_i = graph -> vert[tmp_i];
        while ((graph -> adj2[tmp_i] != 0) && 
            (graph -> adj1[tmp_i] != end_i)) {
            tmp_i = graph -> adj2[tmp_i];
        }
        graph -> adj2[tmp_i] = tmp_i1;
        graph -> adj1[tmp_i1] = end_i;
        graph -> wght[tmp_i1] = weight;
        graph -> source[tmp_i1] = start_i;
    }
    return 0;
}

// returns 0 if successful, 1 if unsuccessful

int graph_del_edge(struct Graph* graph, int start, int end) {
    int start_i = -1, end_i = -1;
    // looking for vertices
    for (int i = 1; i < graph -> actn; i++) {
        if (graph -> vid[i] == start) {
            start_i = i;
        }
        if (graph -> vid[i] == end) {
            end_i = i;
        }
    }

    if ((start_i == -1) || (end_i == -1)) {
        printf("\ngraph_del_edge: WARNING, not all vertex found\n");
        return 1;
    }

    // we found all the vertices, we need to check for the presence of an edge
    int tmp_i = graph -> vert[start_i];
    int prev_i = 0;

    if (tmp_i == 0) {
        printf("\ngraph_del_edge: WARNING, edge not found\n");
        return 1;
    }

    if (graph -> adj1[tmp_i] == end_i) {
        // we consider the edge case when the edge being removed is the first
        graph -> vert[start_i] = graph -> adj2[tmp_i];
        graph -> adj1[tmp_i] = 0;
        graph -> adj2[tmp_i] = 0;
        graph -> wght[tmp_i] = 0;
        graph -> source[tmp_i] = 0;
        return 0;
    }

    while ((graph -> adj2[tmp_i] != 0) && (graph -> adj1[tmp_i] != end_i)) {
        prev_i = tmp_i;
        tmp_i = graph -> adj2[tmp_i];
    }
    /*
    after this cycle, we either got to the end,
    or to the edge that needs to be removed
    */
    if (graph -> adj1[tmp_i] != end_i) {
        // so we didn't find the edge
        printf("\ngraph_del_edge: WARNING, edge not found\n");
        return 1;
    } else {
        /*
        here it is, the edge, prev_i points to the previous
        one, you need to throw the pointer from the previous one to the next
        one and zero the edge itself
        */
        graph -> adj2[prev_i] = graph -> adj2[tmp_i];
        graph -> adj1[tmp_i] = 0;
        graph -> adj2[tmp_i] = 0;
        graph -> wght[tmp_i] = 0;
        graph -> source[tmp_i] = 0;
    }
    return 0;
}

/*
returns the location of a vertex in the vid array, if it exists, 
returns 0 if there is no such vertex
*/
int graph_search_vertex(struct Graph * graph, int vertex) {
    for (int i = 0; i < graph -> actn; i++) {
        if (graph -> vid[i] == vertex)
            return i;
    }
    return 0;
}

/*
Returns the position in the adj array of the edge between
the start and end vertices. If there are no edges, or they have ended,
0 is returned.
*/
int graph_search_edge(struct Graph * graph, int start, int end, 
    int reload_flag) {
    static int calls = 0;
    static int cur_start = 0;
    static int cur_end = 0;
    static int start_i = 0;
    static int end_i = 0;
    static int cur_i = 0;

    if ((cur_start != start) || (cur_end != end) || (calls == 0) || 
        reload_flag) {
        cur_start = start;
        cur_end = end;
        cur_i = 0;
        start_i = 0;
        end_i = 0;
        calls = 0;
    }
    
    if (calls == 0) {
        for (int i = 0; i < graph -> actn; i++) {
            if (graph -> vid[i] == start) {
                start_i = i;
            }
            if (graph -> vid[i] == end) {
                end_i = i;
            }
        }
        if ((start_i == 0) || (end_i == 0)) {
            return 0;
        }

        if (graph -> vert[start_i] == 0) {
            return 0;
        } else {
            cur_i = graph -> vert[start_i];
        }
    }
    while ((graph -> adj1[cur_i] != end_i) && (graph -> adj2[cur_i] != 0)) {
        cur_i = graph -> adj2[cur_i];
    }
    if (graph -> adj2[cur_i] != 0) {
        int old_cur_i = cur_i;
        cur_i = graph -> adj2[cur_i];
        calls++;
        return old_cur_i;
    } else {
        calls = 0;
        if (graph -> adj1[cur_i] != end_i) {
            return 0;
        } else {
            return cur_i;
        }
    }
    return 0;
}


void graph_kill(struct Graph * graph) {
    free(graph -> vert);
    free(graph -> vid);
    free(graph -> adj1);
    free(graph -> adj2);
    free(graph -> source);
    free(graph -> wght);
    free(graph);
}

void print_graph(struct Graph* graph) {
    printf("\nStart printing the graph\n");
    printf("vid:\n");
    for (int i = 0; i < graph -> vert_size; i++) {
        printf(INTFORMAT, i);
    }
    putchar('\n');

    for (int i = 0; i < graph -> vert_size; i++) {
        printf(INTFORMAT, graph -> vid[i]);
    }

    printf("\nVertexes:\n");
    for (int i = 0; i < graph -> vert_size; i++) {
        printf(INTFORMAT, i);
    }
    putchar('\n');
    for (int i = 0; i < graph -> vert_size; i++) {
        printf(INTFORMAT, graph -> vert[i]);
    }
    printf("\nStarting edge printing\n");
    for (int i = 0; i < graph -> edge_size; i++) {
        printf(INTFORMAT, i);
    }
    putchar('\n');
    for (int i = 0; i < graph -> edge_size; i++) {
        printf(INTFORMAT, graph -> adj1[i]);
    }
    putchar('\n');
    for (int i = 0; i < graph -> edge_size; i++) {
        printf(INTFORMAT, graph -> adj2[i]);
    }
    putchar('\n');
    for (int i = 0; i < graph -> edge_size; i++) {
        printf(INTFORMAT, graph -> source[i]);
    }
    putchar('\n');
    for (int i = 0; i < graph -> edge_size; i++) {
        printf(FLOFORMAT, graph -> wght[i]);
    }
    putchar('\n');
}
