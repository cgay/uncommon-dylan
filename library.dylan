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


// A version of common-dylan that has shorter names for some of the
// most commonly used definitions, without loss of readability. There
// are plenty of other long names in the dylan module, but my goal is
// to make the most commonly used ones (<integer> being the prime
// example) slightly less verbose.
define module uncommon-dylan
  use common-dylan,
    rename: { <boolean>   => <bool>,
              <character> => <char>,
              <function>  => <func>,
              <integer>   => <int>,
              <sequence>  => <seq>,
              concatenate    => concat },
    export: all;
  use table-extensions,
    rename: { <case-insensitive-string-table> => <istring-table> },
    export: all;
end module uncommon-dylan;

// Utilities
define module uncommon-utils
  use collection-utilities,
    export: all;
  use uncommon-dylan;
  use streams,
    import: { write,
              with-output-to-string };

  export
    iff,               // iff(test, true, false)
    <singleton-object>,
    string-to-float,
    // Wasn't sure whether to include this, since FunDev already has
    // float-to-string, but decided to keep it with a different name.
    // --cgay
    float-to-formatted-string,
    remove-keys,        // For removing keywords from #rest arglists.
    value-sequence,
    count,

    inc!,              // like ++foo
    dec!,              // like --foo

    <string-trie>,
    find-object,
    add-object,
    remove-object,
    trie-children,
    trie-object,
    <trie-error>,

    <int*>, <int+>,

    slice,
    elt,

    err,
    with-restart,
    with-simple-restart,

    enum-definer,
    enum-value,
    enum-description;
end module uncommon-utils;
