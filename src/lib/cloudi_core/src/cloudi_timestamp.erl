%-*-Mode:erlang;coding:utf-8;tab-width:4;c-basic-offset:4;indent-tabs-mode:()-*-
% ex: set ft=erlang fenc=utf-8 sts=4 ts=4 sw=4 et:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==Timestamp operations==
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2015, Michael Truog <mjtruog at gmail dot com>
%%% All rights reserved.
%%% 
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%% 
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in
%%%       the documentation and/or other materials provided with the
%%%       distribution.
%%%     * All advertising materials mentioning features or use of this
%%%       software must display the following acknowledgment:
%%%         This product includes software developed by Michael Truog
%%%     * The name of the author may not be used to endorse or promote
%%%       products derived from this software without specific prior
%%%       written permission
%%% 
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%%% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
%%% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%%% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
%%% DAMAGE.
%%%
%%% @author Michael Truog <mjtruog [at] gmail (dot) com>
%%% @copyright 2015 Michael Truog
%%% @version 1.5.0 {@date} {@time}
%%%------------------------------------------------------------------------

-module(cloudi_timestamp).
-author('mjtruog [at] gmail (dot) com').

%% external interface
-export([timestamp/0,
         seconds/0,
         seconds_filter/3]).

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% @doc
%% ===Return an Erlang VM timestamp.===
%% Not guaranteed to be strictly monotonically increasing
%% (on Erlang >= 18.0).
%% @end
%%-------------------------------------------------------------------------

-spec timestamp() -> erlang:timestamp().

-ifdef(ERLANG_OTP_VERSION_16).
timestamp() ->
    erlang:now().
-else.
-ifdef(ERLANG_OTP_VERSION_17).
timestamp() ->
    erlang:now().
-else. % necessary for Erlang >= 18.0
timestamp() ->
    erlang:timestamp().
-endif.
-endif.

%%-------------------------------------------------------------------------
%% @doc
%% ===Seconds since the UNIX epoch.===
%% (The UNIX epoch is 1970-01-01T00:00:00)
%% @end
%%-------------------------------------------------------------------------

% calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}})
-define(GREGORIAN_SECONDS_OFFSET, 62167219200).
-ifdef(ERLANG_OTP_VERSION_16).
seconds() ->
    calendar:datetime_to_gregorian_seconds(
        calendar:now_to_universal_time(erlang:now())) -
        ?GREGORIAN_SECONDS_OFFSET.
-else.
-ifdef(ERLANG_OTP_VERSION_17).
seconds() ->
    calendar:datetime_to_gregorian_seconds(
        calendar:now_to_universal_time(erlang:now())) -
        ?GREGORIAN_SECONDS_OFFSET.
-else. % necessary for Erlang >= 18.0
seconds() ->
    erlang:system_time(seconds).
-endif.
-endif.

%%-------------------------------------------------------------------------
%% @doc
%% ===Filter a list of seconds since the UNIX epoch..===
%% The list is not ordered.
%% @end
%%-------------------------------------------------------------------------

seconds_filter(L, SecondsNow, MaxPeriod) ->
    seconds_filter(L, [], SecondsNow, MaxPeriod).

seconds_filter([], Output, _, _) ->
    Output;
seconds_filter([Seconds | L], Output, SecondsNow, MaxPeriod) ->
    if
        (SecondsNow < Seconds) orelse
        ((SecondsNow - Seconds) > MaxPeriod) ->
            seconds_filter(L, Output, SecondsNow, MaxPeriod);
        true ->
            seconds_filter(L, [Seconds | Output], SecondsNow, MaxPeriod)
    end.

%%%------------------------------------------------------------------------
%%% Private functions
%%%------------------------------------------------------------------------

