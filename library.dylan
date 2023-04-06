Module:   dylan-user
Synopsis: Some definitions of general use that could be considered for
          inclusion in common-dylan if they stand the test of time.
Copyright: See LICENSE in this distribution for details.

define library uncommon-dylan
  use collections,
    import: { table-extensions };
  use collection-extensions,
    import: { collection-utilities };
  use common-dylan,
    // Re-export modules other than common-dylan so it's not necessary
    // to use both uncommon-dylan and common-dylan.
    export: { byte-vector,
              common-extensions,
              locators-protocol,
              machine-words,
              simple-format,
              simple-profiling,
              simple-random,
              simple-timers,
              streams-protocol,
              transcendentals };
  use io,
    import: { streams };

  export
    uncommon-dylan,
    uncommon-utils;
end;


// A version of common-dylan that has shorter names for some of the most
// commonly used definitions, without loss of readability, I hope. There are
// plenty of other long names in the dylan module, but my intent is to make the
// most commonly used ones (<integer> and false-or(<integer>) being the prime
// examples) slightly less verbose.
define module uncommon-dylan
  use common-dylan,
    rename: { <boolean>   => <bool>,
              <character> => <char>,
              <function>  => <func>,
              <integer>   => <int>, // see other integer types exported below
              <sequence>  => <seq>,
              concatenate => concat },
    export: all;
  use byte-vector, export: all;
  use simple-format, export: all;
  use simple-profiling, export: all;
  use simple-random, export: all;
  use simple-timers, export: all;
  use table-extensions,
    rename: { <case-insensitive-string-table> => <istring-table> },
    export: all;
end module uncommon-dylan;


define module uncommon-utils
  // Additional numeric types.
  create
    <int>?,                     // false-or(<int>)
    <uint>,                     // min: 0
    <uint>?;                    // false-or(<uint>)

  // Collections
  create
    remove-keys,        // For removing keywords from #rest arglists.
    value-sequence,     // Complement to key-sequence. 
    count,
    slice;

  // Odds and ends
  create
    ash<<, ash>>;

  create
    cond,                       // cond(test, true [, false])
    iff,                        // DEPRECATED - use cond instead
    <singleton-object>,
    inc!, dec!;                 // like foo++ foo--

  // Conditions
  create
    with-restart,
    with-simple-restart;

  create
    string-to-float,
    // Wasn't sure whether to include this, since FunDev already has
    // float-to-string, but decided to keep it with a different name.
    // --cgay
    float-to-formatted-string;

  // Trie
  create
    <string-trie>,
    find-object,
    add-object,
    remove-object,
    trie-children,
    trie-object,
    <trie-error>;

  // enums
  create
    \enum-definer;
end module uncommon-utils;

define module uncommon-utils-internal
  use uncommon-dylan;
  use uncommon-utils;
  use streams,
    import: { write,
              with-output-to-string };
end module;
