%% ----------------------------------------------------------------------------
%%
%% lager_hipchat: HipChat backend for Lager
%%
%% Copyright (c) 2013 Synlay Technologies
%%
%% Permission is hereby granted, free of charge, to any person obtaining a
%% copy of this software and associated documentation files (the "Software"),
%% to deal in the Software without restriction, including without limitation
%% the rights to use, copy, modify, merge, publish, distribute, sublicense,
%% and/or sell copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
%% DEALINGS IN THE SOFTWARE.
%%
%% ----------------------------------------------------------------------------

-module(lager_hipchat_backend).

-behaviour(gen_event).

-export([
         init/1
         ,handle_call/2
         ,handle_event/2
         ,handle_info/2
         ,terminate/2
         ,code_change/3
        ]).

%%% this is only exported for the spawn call
-export([send_log/3]).

-record(state, {
                auth_token      :: string()
                ,room_id        :: string()
                ,sender         :: string()
                ,color          :: string()
                ,mentions       :: [string() | atom()]
                ,notify         :: integer()
                ,level          :: integer()
                ,formatter      :: atom()
                ,format_config
                ,retry_interval :: integer()
                ,retry_times    :: integer()
               }).

-include_lib("lager/include/lager.hrl").

-define (HIPCHAT_API_URL, "https://api.hipchat.com/v1/rooms/message").
-define (HIPCHAT_API_REQUEST (Data), {?HIPCHAT_API_URL, [], "application/x-www-form-urlencoded", Data}).

-define(DEFAULT_FORMAT, ["[", severity, "] ",
                         {pid, ""},
                         {module, [
                                   {pid, ["@"], ""},
                                   module,
                                   {function, [":", function], ""},
                                   {line, [":",line], ""}], ""},
                         " ", message]).

init([AuthToken, RoomId, Sender, Color, Mentions, Notify, Level, RetryTimes, RetryInterval]) ->
    init([AuthToken, RoomId, Sender, Color, Mentions, Notify, Level, {lager_default_formatter, ?DEFAULT_FORMAT}, RetryTimes, RetryInterval]);
init([AuthToken, RoomId, Sender, Color, Mentions, Notify, Level, {Formatter, FormatterConfig}, RetryTimes, RetryInterval]) 
    when is_list(RoomId), is_list(Sender), is_list(Mentions), is_boolean(Notify), is_atom(Formatter) ->

    State = #state{
                   auth_token      = AuthToken
                   ,room_id        = RoomId
                   ,sender         = Sender
                   ,color          = any_to_list(Color)
                   ,mentions       = any_to_list(Mentions)
                   ,notify         = any_to_list(Notify)
                   ,level          = lager_util:level_to_num(Level)
                   ,formatter      = Formatter
                   ,format_config  = FormatterConfig
                   ,retry_interval = RetryInterval
                   ,retry_times    = RetryTimes
                  },
    {ok, State}.

handle_call(get_loglevel, #state{ level = Level } = State) ->
    {ok, Level, State};
handle_call({set_loglevel, Level}, State) ->
    {ok, ok, State#state{ level = lager_util:level_to_num(Level) }};
handle_call(_Request, State) ->
    {ok, ok, State}.

handle_event({log, Message}, #state{ auth_token = AuthToken, color = Color, mentions = Mentions,
                                     room_id = RoomId, sender = Sender, notify = Notify, level = Level,
                                     formatter = Formatter, format_config = FormatterConfig,
                                     retry_times = RetryTimes, retry_interval = RetryInterval} = State) ->

    case lager_util:is_loggable(Message, Level, ?MODULE) of
        true ->
            Data = [{"format", "json"}, {"auth_token", AuthToken},
                    {"room_id", RoomId}, {"color", Color},
                    {"message_format", "text"}, {"message", convert_lager_message(Message, Formatter, FormatterConfig, Mentions)},
                    {"notify", Notify}, {"from", Sender}],

            spawn(?MODULE, send_log, [?HIPCHAT_API_REQUEST(url_encode(Data)), RetryTimes, RetryInterval]),

            {ok, State};
        false ->
            {ok, State}
    end;
handle_event(_Event, State) ->
    {ok, State}.

handle_info(_Info, State) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%% Private

-spec(url_encode([{string(), string()}]) -> string()).
url_encode(Attributes) ->
    url_encode(Attributes, "").

url_encode([], Acc) ->
    Acc;
url_encode([{Key, Value} | Rest], "") when is_list(Key),
                                           is_list(Value) ->
    url_encode(Rest, edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value));
url_encode([{Key, Value} | Rest], Acc) when is_list(Key),
                                            is_list(Value) ->
    url_encode(Rest, Acc ++ "&" ++ edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value)).

-spec(send_log(Request :: term(), Retries :: integer(), Interval :: integer()) -> ok).
send_log(_Request, 0, _) ->
    ok;
send_log(Request, Retries, Interval) ->

    case httpc:request(post, Request, [], [{sync, true}]) of
        {ok, {{_, 200, _}, _Headers, _Body}} -> ok;
        _Response ->
            timer:sleep(Interval * 1000),
            send_log(Request, Retries - 1, Interval)
    end.

-spec(convert_lager_message(Message::lager_msg:lager_msg(), Formatter::atom(), FormatterConfig::list(), Mentions::[string()]) -> string()).
convert_lager_message(Message, Formatter, FormatterConfig, Mentions) ->
    convert_lager_message(Message, Formatter, FormatterConfig, Mentions, "").

convert_lager_message(Message, Formatter, FormatterConfig, [UserToMention | Rest], MentionsAcc) ->
    convert_lager_message(Message, Formatter, FormatterConfig, Rest, MentionsAcc ++ " @" ++ UserToMention);
convert_lager_message(Message, Formatter, FormatterConfig, [], MentionsAcc) ->
    binary_to_list(iolist_to_binary(Formatter:format(Message, FormatterConfig))) ++ MentionsAcc.

any_to_list([], Acc)                                 -> Acc;
any_to_list([Value | Rest], Acc) when is_list(Value) -> any_to_list(Rest, [Value | Acc]);
any_to_list([Value | Rest], Acc)                     -> any_to_list(Rest, [any_to_list(Value) | Acc]).

any_to_list(List=[_Value | _Rest])     -> any_to_list(List, []);
any_to_list(true)                      -> "1";
any_to_list(false)                     -> "0";
any_to_list(Value) when is_atom(Value) -> atom_to_list(Value);
any_to_list(Value)                     -> Value.
