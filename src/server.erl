-module(server).

-import(io,[fwrite/2, fwrite/1]).
-import(lists,[sum/1,nth/2]).

-export([server/3]).

server(PIDs, Max_Blocks, Trace) ->
    [Node ! {update_pids, PIDs} || Node <- PIDs],
    hd(PIDs) ! {update_last, hd(PIDs), {self(), -1, []}},
    hd(PIDs) ! {generate_block},
    server(PIDs, hd(PIDs), hd(PIDs), -1, Max_Blocks, Trace).

server(PIDs, Elected_Node, Last_Pusher, Last_Block, Max_Blocks, Trace) ->
    receive
        {elected_node, New_Elected_Node} ->
            if 
                Trace ->
                    fwrite("Server ~p recieved message ~p.\n", [self(), {elected_node, New_Elected_Node}]);
                true ->
                    pass
            end,
            PID_Elected = nth(New_Elected_Node + 1, PIDs),
            PID_Elected ! {generate_block},
            server(PIDs, PID_Elected, Last_Pusher, Last_Block, Max_Blocks, Trace);

        {generated_claim, Generated_Claim} ->
            if 
                Trace ->
                    fwrite("Server ~p recieved message ~p.\n", [self(), {generated_claim, Generated_Claim}]);
                true ->
                    pass
            end,
            Last_Pusher ! {receive_claim, Generated_Claim},
            server(PIDs, Elected_Node, Last_Pusher, Last_Block, Max_Blocks, Trace);

        {generated_block, New_Block} ->
            if 
                Trace ->
                    fwrite("Server ~p recieved message ~p.\n", [self(), {generated_block, New_Block}]);
                true ->
                    pass
            end,
            [Node ! {update_last, Elected_Node, New_Block} || Node <- PIDs],
            if
                element(2, New_Block) < Max_Blocks ->
                    [Node ! {generate_claim} || Node <- PIDs],
                    server(PIDs, Elected_Node, Elected_Node, New_Block, Max_Blocks, Trace);
                element(2, New_Block) >= Max_Blocks ->
                    [Node ! terminate || Node <- PIDs],
                    if 
                        Trace ->
                            fwrite("Server terminated.\n");
                        true ->
                            pass
                    end,
                    New_Block
            end
            
    end.