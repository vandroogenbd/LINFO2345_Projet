-module(pos_node).
-import(io,[fwrite/2, fwrite/1]).
-export([pos_node_loop/1]).

pos_node_loop(SeqNum) ->
    fwrite("Je suis le noeud ~p.\n", [SeqNum]),
    receive
        {PID_List} ->
            network = PID_List;
        print_name ->
            fwrite("Je suis un noeud.\n");
        unknown_case ->
            fwrite("Que dois-je faire de ~p? Dans le doute, je stoppe!\n", [unknown_case]);
        _ ->
            ok
    end,
    pos_node_loop(SeqNum).