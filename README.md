BrowserLang
===========

An OTP library for parsing language Http headers with zero dependencies.

Requirements
------------
Erlang R17 or higher (due to use of Maps) and Rebar 3.

License
-------
Apache 2.0

Build
-----

    $ rebar3 compile
 

Generate documentation    
----------------------
    $ rebar3 edoc

Usage
-----

    Eshell V8.1  (abort with ^G)
    1> browser_lang:parse_accept_language(<<"da, en-gb;q=0.8, en-us;q=0.9">>).         
    [#{lang => <<"da">>,locale => undefined,quality => 1.0},
     #{lang => <<"en">>,locale => <<"en-us">>,quality => 0.9},
     #{lang => <<"en">>,locale => <<"en-gb">>,quality => 0.8}]

`browser_lang:parse_accept_language/1`
------------------

* `browser_lang:parse_accept_language(binary()) -> [Map :: map()]`

Function for parsing Accept-Language header. Header string should be 
a binary. Returns sorted list of a parsed language ranges. Sorting is 
based upon quality *"q"* param of each language or locale tag. Each 
resulting element is a Map of a three keys: **lang**, **locale** and 
**quality**. Locale could be undefined. 

All returned values will always be in lowercase.