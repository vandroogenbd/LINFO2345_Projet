-module(test).

-import(io,[fwrite/2, fwrite/1]).

-compile(export_all).


pipou() ->
    dolphin = spawn(?MODULE, dolphin3, []),
    dolphin ! {}.

dolphin1() ->
    receive
        do_a_flip ->
            io:format("How about no?~n");
        fish ->
            io:format("So long and thanks for all the fish!~n");
        _ ->
            io:format("Heh, we're smarter than you humans.~n")
    end.

dolphin2() ->
    receive
        {From, do_a_flip} ->
            From ! "How about no?";
        {From, fish} ->
            From ! "So long and thanks for all the fish!";
        _ ->
            io:format("Heh, we're smarter than you humans.~n")
    end.

dolphin3() ->
    receive
        {From, do_a_flip} ->
            From ! "How about no?",
            dolphin3();
        {From, fish} ->
            From ! "So long and thanks for all the fish!";
        _ ->
            io:format("Heh, we're smarter than you humans.~n"),
            dolphin3()
    end.

run(0, _) ->
    fwrite("Fuck les dauphins.\n");
run(N, Dolphin) when N > 0 ->
    Dolphin ! {self(), do_a_flip},
    run(N-1, Dolphin).

run(N) ->
    dolphins = spawn(dolphin3()),
    run(N, dolphins).