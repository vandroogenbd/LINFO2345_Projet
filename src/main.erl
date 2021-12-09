-module(main).

-import(lists,[append/2]).
-import(io,[fwrite/2, fwrite/1]).

-export([run/1]).

run(N) ->
    spawn(start_nodes(N, [])).

start_nodes(0, Array) ->
    Array;
start_nodes(N, Array) ->
    pid = spawn(pos_node, pos_node_loop, [N]),
    fwrite("J'ai lancé le noeud ~p.\n", [N]),
    temp = append(Array, [pid]),
    pid ! print_name,
    start_nodes(N - 1, temp).