-module(main).

-import(io,[fwrite/2, fwrite/1]).
-import(server,[server/3]).

-export([run/1]).

run(N) ->
    % Change this value to change the amout of blocks the network will generate before stopping
    Max_Blocks = 3,
    % Set this value to true to have a simple trace using prints
    Trace = false,

    PIDs = start_nodes(1, N, fun() -> spawn(pos_node, pos_node_loop, [self(), [], -1, -1, [], Trace]) end),
    if
        Trace ->
            fwrite("Generated nodes ~p\n\n", [PIDs]);
        true ->
            pass
    end,
    server(PIDs, Max_Blocks, Trace).

start_nodes(N, N, F) -> [F()]; 
start_nodes(I, N, F) -> [F()|start_nodes(I+1, N, F)].