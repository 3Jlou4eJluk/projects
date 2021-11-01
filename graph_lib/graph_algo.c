#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "graph.h"
#include "graph_algo.h"


/*
Dijkstra's algorithm assumes that
an oriented graph without loops and multiple edges is fed to the input.
The graph containing the shortest path is returned.
*/

struct Graph* dijkstra(struct Graph * graph, int start, int end) {
    int start_i = 0, end_i = 0;
    int vert_quan = 0;
    int cur_i;
    for (int i = 1; i < graph -> actn; i++) {
        if (graph -> vid[i] == start) {
            start_i = i;
        }
        if (graph -> vid[i] == end) {
            end_i = i;
        }
        if (graph -> vid[i] != 0) {
            vert_quan++;
        }
    }
    if ((start_i == 0) || (end_i == 0)) {
        printf("\ndijkstra: I dunno da wae\n");
        return NULL;
    }
    // vertexes found

    int *vis_arr = calloc(graph -> vert_size, sizeof(int));
    int *from_arr = calloc(graph -> vert_size, sizeof(int));
    double *st_dist = calloc(graph -> vert_size, sizeof(double));
    for (int i = 0; i < graph -> vert_size; i++) {
        vis_arr[i] = 0;
        from_arr[i] = 0;
        st_dist[i] = INFINITY;
    }
    st_dist[start_i] = 0;

    struct Graph * wae = graph_init();

    int proc_quan = 0;
    while (proc_quan < vert_quan) {
        // looking for the minimum raw vertex
        double minn = INFINITY;
        cur_i = 0;
        for (int i = 0; i < graph -> vert_size; i++) {
            if ((graph -> vid[i] != 0) && (vis_arr[i] == 0) && 
                (st_dist[i] < minn)) {
                minn = st_dist[i];
                cur_i = i;
            }
        }
        if (graph -> vert[cur_i] == 0) {
            vis_arr[cur_i] = 1;
            proc_quan++;
        } else {
            int old_i = cur_i;
            cur_i = graph -> vert[cur_i];
            if (st_dist[old_i] + graph -> wght[cur_i] < \
                st_dist[graph -> adj1[cur_i]]) {
                st_dist[graph -> adj1[cur_i]] = \
                st_dist[old_i] + graph -> wght[cur_i];
                from_arr[graph -> adj1[cur_i]] =  old_i;
            }
            while(graph -> adj2[cur_i] != 0) {
                cur_i = graph -> adj2[cur_i];
                if (st_dist[old_i] + graph -> wght[cur_i] < \
                    st_dist[graph -> adj1[cur_i]]) {
                    st_dist[graph -> adj1[cur_i]] = \
                    st_dist[old_i] + graph -> wght[cur_i];
                    from_arr[graph -> adj1[cur_i]] =  old_i;
                }
            }
            vis_arr[old_i] = 1;
            proc_quan++;
        }
    }
    if (st_dist[end_i] == INFINITY) {
        printf("\ndijkstra: I dunno da wae\n");
        free(vis_arr);
        free(from_arr);
        free(st_dist);
        graph_kill(wae);
        return NULL;
    }
    
    // starting the construction of the path graph
    graph_add_vertex(wae, start);
    for (int i = 1; i < graph -> actn; i++) {
        if ((i != start_i) && (from_arr[i] != 0)) {
            graph_add_edge(wae, graph -> vid[from_arr[i]], graph -> vid[i],
                graph -> wght[graph_search_edge(graph, 
                graph -> vid[from_arr[i]], graph -> vid[i], 1)]);
        }
    }
    free(vis_arr);
    free(from_arr);
    free(st_dist);
    return wae;
}