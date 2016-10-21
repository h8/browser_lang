-module(browser_lang_tests).
-author("Dmitry Stropalov <d.stropalov@gmail.com>").

-include_lib("eunit/include/eunit.hrl").

parse_accept_language_empty_test() ->
  ?assertEqual([], browser_lang:parse_accept_language(<<>>)),
  ?assertEqual([], browser_lang:parse_accept_language(<<"">>)).

parse_accept_language_ignore_case_test() ->
  ?assertEqual(
    [
      #{lang => <<"da">>, locale => undefined, quality => 1.0},
      #{lang => <<"en">>, locale => <<"en-gb">>, quality => 0.8},
      #{lang => <<"en">>, locale => undefined, quality => 0.7}
    ],
    browser_lang:parse_accept_language(<<"dA, EN-GB;Q=0.8, En;q=0.7">>)).

parse_accept_language_quality_test() ->
  ?assertEqual(
    [
      #{lang => <<"da">>, locale => undefined, quality => 1.0},
      #{lang => <<"en">>, locale => <<"en-us">>, quality => 0.9},
      #{lang => <<"en">>, locale => <<"en-gb">>, quality => 0.8},
      #{lang => <<"en">>, locale => undefined, quality => 0.7}
    ],
    browser_lang:parse_accept_language(<<"da, en-gb;q=0.8, en;q=0.7, en-us;q=0.9">>)).

parse_accept_language_corrupted_test() ->
  ?assertEqual(
    [
      #{lang => <<"da">>, locale => undefined, quality => 1.0}
    ],
    browser_lang:parse_accept_language(<<"da, en-gb;q=0.8a, en;q=0.7; en-us;q=0.9">>)),

  ?assertEqual(
    [
      #{lang => <<"en">>, locale => <<"en-us">>, quality => 0.9},
      #{lang => <<"en">>, locale => undefined, quality => 0.7}
    ],
    browser_lang:parse_accept_language(<<"da; en-gb;q=0.8a, en;q=0.7, en-us;q=0.9">>)),

  ?assertEqual(
    [
      #{lang => <<"da">>, locale => undefined, quality => 1.0},
      #{lang => <<"en">>, locale => undefined, quality => 0.7}
    ],
    browser_lang:parse_accept_language(<<"da, ;q=0.8, en;q=0.7">>)),

  ?assertEqual(
    [
      #{lang => <<"da">>, locale => undefined, quality => 1.0}
    ],
    browser_lang:parse_accept_language(<<"da, ,;q=0.8, en;q=0.7a">>)).

parse_lang_range_explicit_quality_test() ->
  ?assertEqual(#{lang => <<"en">>, locale => <<"en-us">>, quality => 0.8},
    browser_lang:parse_lang_range(<<"en-us;q=0.8">>)),

  ?assertEqual(#{lang => <<"a">>, locale => undefined, quality => 0.1},
    browser_lang:parse_lang_range(<<"a;q=0.1">>)),

  ?assertEqual(#{lang => <<"en">>, locale => undefined, quality => 0.1},
    browser_lang:parse_lang_range(<<"en-;q=0.1">>)).

parse_lang_range_default_quality_test() ->
  ?assertEqual(#{lang => <<"en">>, locale => <<"en-us">>, quality => 1.0},
    browser_lang:parse_lang_range(<<"en-us">>)),

  ?assertEqual(#{lang => <<"de">>, locale => undefined, quality => 1.0},
    browser_lang:parse_lang_range(<<"de">>)).

parse_lang_range_corrupted_test() ->
  ?assertEqual(undefined, browser_lang:parse_lang_range(<<"">>)),
  ?assertEqual(undefined, browser_lang:parse_lang_range(<<>>)),
  ?assertEqual(undefined, browser_lang:parse_lang_range(<<";q=0.1">>)).

lang_and_locale_both_test() ->
  ?assertEqual(#{lang => <<"en">>, locale => <<"en-us">>},
    browser_lang:lang_and_locale(<<"en-us">>)),

  ?assertEqual(#{lang => <<"zh">>, locale => <<"zh-hant-mo">>},
    browser_lang:lang_and_locale(<<"zh-hant-mo">>)).

lang_and_locale_lang_only_test() ->
  ?assertEqual(#{lang => <<"en">>, locale => undefined},
    browser_lang:lang_and_locale(<<"en">>)),

  ?assertEqual(#{lang => <<"en">>, locale => undefined},
    browser_lang:lang_and_locale(<<"en-">>)),

  ?assertEqual(#{lang => <<"enus">>, locale => undefined},
    browser_lang:lang_and_locale(<<"enus">>)).

lang_and_locale_empty_test() ->
  ?assertEqual(undefined, browser_lang:lang_and_locale(<<>>)),
  ?assertEqual(undefined, browser_lang:lang_and_locale(<<"">>)).

quality_default_empty_test() ->
  ?assertEqual(1.0, browser_lang:quality(<<"">>)),
  ?assertEqual(1.0, browser_lang:quality(<<>>)).

quality_non_empty_test() ->
  ?assertEqual(1.0, browser_lang:quality(<<"1.0">>)),
  ?assertEqual(0.5, browser_lang:quality(<<"0.5">>)).
