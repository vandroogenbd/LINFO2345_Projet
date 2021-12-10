-module(pos_node).

-import(io,[fwrite/2, fwrite/1]).
-import(lists,[sum/1]).

-export([pos_node_loop/5]).

pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims) ->
    receive
        {update_pids, New_PID_List} ->
            fwrite("Je suis le noeud ~p et j'ai recu le message ~p.\n", [self(), {update_pids, New_PID_List}]),
            pos_node_loop(Server, New_PID_List, Last_Pusher, Last_Block, Claims);

        {update_last, New_Last_Pusher, New_Last_Block} ->
            fwrite("Je suis le noeud ~p et j'ai recu le message ~p.\n", [self(), {update_last, New_Last_Pusher, New_Last_Block}]),
            pos_node_loop(Server, PID_List, New_Last_Pusher, New_Last_Block, Claims);

        {receive_claim, Claim} ->
            fwrite("Je suis le noeud ~p et j'ai recu le message ~p.\n", [self(), {receive_claim, Claim}]),
            New_Claims = [Claim | Claims],
            if
                ( (length(PID_List) - 1) == length(New_Claims) ) ->
                    Sum_Claims = sum(New_Claims),
                    Elected_Node = Sum_Claims rem length(PID_List),
                    Server ! {elected_node, Elected_Node},
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, []);
                ( (length(PID_List) - 1) > length(New_Claims) ) ->
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, New_Claims)
            end;

        {generate_claim} ->
            fwrite("Je suis le noeud ~p et j'ai recu le message ~p.\n", [self(), {generate_claim}]),
            if
                self() =/= Last_Pusher ->
                    Generated_Claim = rand:uniform(100),
                    Server ! {generated_claim, Generated_Claim},
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims);
                self() == Last_Pusher ->
                    pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims)
            end;

        {generate_block} ->
            fwrite("Je suis le noeud ~p et j'ai recu le message ~p.\n", [self(), {generate_block}]),
            New_Block = {self(), element(2, Last_Block) + 1, Last_Block},
            Server ! {generated_block, New_Block},
            pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims);

        print_name ->
            fwrite("Je suis le noeud ~p.\n", [self()]),
            pos_node_loop(Server, PID_List, Last_Pusher, Last_Block, Claims);

        terminate ->
            fwrite("Noeud fini.\n"),
            terminate_node
    end.