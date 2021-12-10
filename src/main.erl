-module(main).

-import(io,[fwrite/2, fwrite/1]).
-import(server,[server/1]).

-export([run/1]).

run(N) ->
    PIDs = start_nodes(1, N, fun() -> spawn(pos_node, pos_node_loop, [self(), [], -1, -1, []]) end),
    fwrite("Noeuds lances ~p\n", [PIDs]),
    server(PIDs).

start_nodes(N, N, F) -> [F()]; 
start_nodes(I, N, F) -> [F()|start_nodes(I+1, N, F)].
