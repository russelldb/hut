%% -*- erlang -*-

-ifndef(__HUT_HRL__).
-define(__HUT_HRL__, true).

%% Supported logging levels (taken from lager):
-define(log_levels, [debug, info, notice, warning, error, critical, alert, emergency]).

%% Helper macros
-define(__fmt(__Fmt, __Args), lists:flatten(io_lib:format(__Fmt, __Args))).

%% Lager support
-ifdef(HUT_LAGER).
-define(log_type, "lager").

-ifndef(HUT_LAGER_SINK).
-define(HUT_LAGER_SINK, lager).
-endif.

-define(log(__Level, __Fmt), ?HUT_LAGER_SINK:__Level([], __Fmt, [])).
-define(log(__Level, __Fmt, __Args), ?HUT_LAGER_SINK:__Level([], __Fmt, __Args)).
-define(log(__Level, __Fmt, __Args, __Opts), ?HUT_LAGER_SINK:__Level(__Opts, __Fmt, __Args)).

-else.

% Using plain `io:format/2`.
-ifdef(HUT_IOFORMAT).
-define(log_type, "ioformat").

-define(log(__Level, __Fmt), io:format("~p: " ++ __Fmt ++ "~n", [__Level])).
-define(log(__Level, __Fmt, __Args), io:format("~p: " ++ __Fmt ++ "~n", [__Level] ++ __Args)).
-define(log(__Level, __Fmt, __Args, __Opts), io:format("~p: " ++ __Fmt ++ "; Opts: ~p~n", [__Level] ++ __Args ++ [__Opts])).

-else.

% All logging calls are passed into a custom logging callback module given by `HUT_CUSTOM_CB`.
-ifdef(HUT_CUSTOM).
-ifdef(HUT_CUSTOM_CB).
-define(log_type, "custom").

-define(log(__Level, __Fmt), ?HUT_CUSTOM_CB:log(__Level, __Fmt, [], [])).
-define(log(__Level, __Fmt, __Args), ?HUT_CUSTOM_CB:log(__Level, __Fmt, __Args, [])).
-define(log(__Level, __Fmt, __Args, __Opts), ?HUT_CUSTOM_CB:log(__Level, __Fmt, __Args, __Opts)).

-endif.
-else.

% All logging calls are ignored.
-ifdef(HUT_NOOP).
-define(log_type, "noop").

-define(log(__Level, __Fmt), true).
-define(log(__Level, __Fmt, __Args), true).
-define(log(__Level, __Fmt, __Args, __Opts), true).

-else.

% If none of the above options was defined, we default to using OTP sasl's error_logger.
-define(log_type, "default").

-define(__log_error_logger(__Level, __Fmt, __Args, __Opts),
        ((fun() ->
                  case __Level of
                      info ->
                          error_logger:info_report([{msg, ?__fmt(__Fmt, __Args)}, {options, __Opts}]);
                      warning ->
                          error_logger:warning_report([{msg, ?__fmt(__Fmt, __Args)}, {options, __Opts}]);
                      error ->
                          error_logger:error_report([{msg, ?__fmt(__Fmt, __Args)}, {options, __Opts}]);
                      __L when __L == debug; __L == notice ->
                          error_logger:info_report([{sublevel, __L}, {msg, ?__fmt(__Fmt, __Args)}, {options, __Opts}]);
                      __L2 when __L2 == critical; __L2 == alert; __L2 == emergency ->
                          error_logger:error_report([{sublevel, __L2}, {msg, ?__fmt(__Fmt, __Args)}, {options, __Opts}]);
                      _ ->
                          ok
                  end
          end)())).
-define(log(__Level, __Fmt), ?__log_error_logger(__Level, __Fmt, [], [])).
-define(log(__Level, __Fmt, __Args), ?__log_error_logger(__Level, __Fmt, __Args, [])).
-define(log(__Level, __Fmt, __Args, __Opts), ?__log_error_logger(__Level, __Fmt, __Args, __Opts)).

% End of all actual log implementation switches.
-endif.
-endif.
-endif.
-endif.

% End of log declarations
-endif.
