%%% @doc Http language headers parsing helper functions.
-module(browser_lang).
-author("Dmitry Stropalov <d.stropalov@gmail.com>").

%% API exports
-export([parse_accept_language/1]).

%% Private exports
-ifdef(EUNIT).
-export([parse_lang_range/1, lang_and_locale/1, quality/1]).
-endif.

-define(LANG_RANGE_RE, "^(?<tag>[\\w\\-]+)(?:;q=(?<quality>[\\d\\.]+))?$").
-define(LANG_RANGE_GROUPS, [tag, quality]).

-define(LANG_LOCALE_RE, "^(?<lang>\\w+)-{0,1}(?<rest>[\\w\\-]*)$").

%%====================================================================
%% API functions
%%====================================================================
-spec(parse_accept_language(binary()) -> [Map :: map()]).
%% @spec parse_accept_language(HeaderBin::binary()) -> List
%% where
%%       HeaderBin = binary(),
%%       List = [Map :: map()]
%% @doc Returns sorted list of parsed language ranges.
%% Sorting is based upon quality "q" param of each language or locale tag.
%% Each resulting element is a Map of three keys:
%% <b>lang</b>, <b>locale</b> and <b>quality</b>.
%% Locale could be undefined. All values always in lowercase.
%%
%% For example: if header string is:
%%
%% &lt;&lt;"en, en-gb;q=0.9"&gt;&gt;
%%
%% result will be:
%%
%% [#{lang =&gt; "en", locale =&gt; undefined, quality =&gt; 1.0},
%% #{lang =&gt; "en", locale =&gt; "en-gb", quality =&gt; 0.9}]
parse_accept_language(<<>>) -> [];
parse_accept_language(HeaderBin) when is_binary(HeaderBin)->
  RangesBin = cleanup_header(HeaderBin),
  RangesList = binary:split(RangesBin, <<",">>, [global]),
  ParsedRanges = lists:filtermap(fun range_parse_filter/1, RangesList),
  lists:sort(fun range_comparator/2, ParsedRanges).

%%====================================================================
%% Internal functions
%%====================================================================
-spec(range_comparator(Map :: map(), Map :: map()) -> boolean()).
range_comparator(#{quality := Q1}, #{quality := Q2}) -> Q1 > Q2.

-spec(range_parse_filter(binary()) -> {true, #{}} | false).
range_parse_filter(RangeBin) ->
  case parse_lang_range(RangeBin) of
    Range when is_map(Range) -> {true, Range};
    _ -> false
  end.

-spec(cleanup_header(binary()) -> binary()).
cleanup_header(HeaderBin) when is_binary(HeaderBin) ->
  HeaderStr = unicode:characters_to_list(HeaderBin),
  HeaderStrCl = re:replace(HeaderStr, "\\s+", "", [global, {return, list}]),
  unicode:characters_to_binary(string:to_lower(HeaderStrCl)).

%% @hidden
-spec(parse_lang_range(binary()) -> Map :: map() | undefined).
parse_lang_range(Range) when is_binary(Range) ->
  {ok, Re} = re:compile(?LANG_RANGE_RE, [unicode]),
  case re:run(Range, Re, [{capture, ?LANG_RANGE_GROUPS, binary}]) of
    {match, Capture} -> capture_to_lang_map(Capture);
    _ -> undefined
  end.

-spec(capture_to_lang_map([binary()]) -> Map :: map() | undefined).
capture_to_lang_map(Captures) when is_list(Captures), length(Captures) == 2 ->
  #{tag := T, quality := Q} =
    maps:from_list(lists:zip(?LANG_RANGE_GROUPS, Captures)),
  case lang_and_locale(T) of
    LL when is_map(LL) -> LL#{quality => quality(Q)};
    _ -> undefined
  end.

%% @hidden
-spec(quality(binary()) -> float()).
quality(<<>>) -> 1.0;
quality(Q) -> binary_to_float(Q).

%% @hidden
-spec(lang_and_locale(binary()) -> Map :: map() | undefined).
lang_and_locale(T) ->
  {ok, Re} = re:compile(?LANG_LOCALE_RE, [unicode]),
  case re:run(T, Re, [{capture, [lang, rest], binary}]) of
    {match, [Lang, <<>>]} -> #{lang => Lang, locale => undefined};
    {match, [Lang, _]} -> #{lang => Lang, locale => T};
    _ -> undefined
  end.
