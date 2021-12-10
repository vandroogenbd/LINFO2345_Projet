-module(pos_node).

-import(io,[fwrite/2, fwrite/1]).
-import(lists,[sum/1]).

-export([pos_node_loop/6]).

pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims, Trace) ->
    receive
        {update_pids, New_PID_List} ->
            if
                Trace ->
                    fwrite("Node ~p recieved message ~p.\n", [self(), {update_pids, New_PID_List}]);
                true ->
                    pass
            end,
            pos_node_loop(Server, New_PID_List, Last_Pusher, Last_Block, Claims, Trace);

        {update_last, New_Last_Pusher, New_Last_Block} ->
            if
                Trace ->
                    fwrite("Node ~p recieved message ~p.\n", [self(), {update_last, New_Last_Pusher, New_Last_Block}]);
                true ->
                    pass
            end,
            pos_node_loop(Server, PID_List, New_Last_Pusher, New_Last_Block, Claims, Trace);

        {receive_claim, Claim} ->
            if
                Trace ->
                    fwrite("Node ~p recieved message ~p.\n", [self(), {receive_claim, Claim}]);
                true ->
                    pass
            end,
            New_Claims = [Claim | Claims],
            if
                ( (length(PID_List) - 1) == length(New_Claims) ) ->
                    Sum_Claims = sum(New_Claims),
                    Elected_Node = Sum_Claims rem length(PID_List),
                    Server ! {elected_node, Elected_Node},
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, [], Trace);
                ( (length(PID_List) - 1) > length(New_Claims) ) ->
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, New_Claims, Trace)
            end;

        {generate_claim} ->
            if
                Trace ->
                    fwrite("Node ~p recieved message ~p.\n", [self(), {generate_claim}]);
                true ->
                    pass
            end,
            if
                self() =/= Last_Pusher ->
                    Generated_Claim = rand:uniform(100),
                    Server ! {generated_claim, Generated_Claim},
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims, Trace);
                self() == Last_Pusher ->
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims, Trace)
            end;

        {generate_block} ->
            if
                Trace ->
                    fwrite("Node ~p recieved message ~p.\n", [self(), {generate_block}]);
                true ->
                    pass
            end,
            New_Block = {self(), element(2, Last_Block) + 1, Last_Block},
            Server ! {generated_block, New_Block},
            pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims, Trace);

        terminate ->
            if
                Trace ->
                    fwrite("Node ~p terminated.\n", [self()]);
                true ->
                    pass
            end,
            terminate_node
    end.