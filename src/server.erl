-module(server).

-import(io,[fwrite/2, fwrite/1]).
-import(lists,[sum/1,nth/2]).

-export([server/1]).

server(PIDs) ->
    [Node ! {update_pids, PIDs} || Node <- PIDs],
    hd(PIDs) ! {update_last, hd(PIDs), {self(), -1, []}},
    hd(PIDs) ! {generate_block},
    server(PIDs, hd(PIDs), hd(PIDs), -1).

server(PIDs, Elected_Node, Last_Pusher, Last_Block) ->
    receive
        {elected_node, New_Elected_Node} ->
            fwrite("Je suis le server ~p et j'ai recu le message ~p.\n", [self(), {elected_node, New_Elected_Node}]),
            PID_Elected = nth(New_Elected_Node + 1, PIDs),
            PID_Elected ! {generate_block},
            server(PIDs, PID_Elected, Last_Pusher, Last_Block);

        {generated_claim, Generated_Claim} ->
            fwrite("Je suis le server ~p et j'ai recu le message ~p.\n", [self(), {generated_claim, Generated_Claim}]),
            Last_Pusher ! {receive_claim, Generated_Claim},
            server(PIDs, Elected_Node, Last_Pusher, Last_Block);

        {generated_block, New_Block} ->
            fwrite("Je suis le server ~p et j'ai recu le message ~p.\n", [self(), {generated_block, New_Block}]),
            [Node ! {update_last, Elected_Node, New_Block} || Node <- PIDs],
            if
                element(2, New_Block) < 5 ->
                    [Node ! {generate_claim} || Node <- PIDs],
                    server(PIDs, Elected_Node, Elected_Node, New_Block);
                element(2, New_Block) >= 5 ->
                    fwrite("Server fini.\n"),
                    [Node ! terminate || Node <- PIDs]
            end
            
    end.