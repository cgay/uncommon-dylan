Module: uncommon-utils

// A simple 'define enum' macro that provides
//   * a type to dispatch on
//   * a set of constants to reference
//   * a name associated with each enum value
//   * no need to use symbols (i.e., leaky abstraction)

// Motivation
//
// There's a Dylan pattern of using a set of symbols like #"passed", #"failed",
// #"skipped" for what in other languages would be an enum. Using symbols like
// this creates a leaky abstraction which can result in developers or users of
// the library using the symbols directly. You really want to at least define a
// set of constants bound to the symbols, and use those instead, so that you
// (a) get compile-time errors when you misspell the name, (b) get cross
// references that make it easy to find what the symbol represents in the code,
// and (c) can easily change the name of the symbol in one place if that's
// necessary.
//
// In addition to all that you're likely to want to define a type union that
// includes all of the symbols so that you can dispatch on it.
//
//
// Implementation Notes
//
// 1. We rely on the compiler to generate warnings for duplicate enum clause
//    names. This should work fine because each clause defines its own
//    constant.
//
// 2. I wanted to make 'define enum' look like this:
//
//       define enum <result> () passed; failed; skipped; end
//
//    rather than the current syntax:
//
//       define enum <result> () $result-passed; $result-failed; $result-skipped; end
//
//    But it turns out that there's a limitation in Dylan macros that prevents the
//    more concise syntax from working if I want the generated constant names to
//    look like $result-foo: you can only use ## concatenation with
//
//       LITERAL-STRING ## NAME ## LITERAL-STRING
//
//    and apparently only a maximum of two ##'s strung together, so this won't work:
//
//       "$" ## ?enum-class-name ## "-" ## ?enum-value-name
//
//    I was unable to find a way to work around this.


define macro enum-definer
  { define enum "<" ## ?enum-name:name ## ">" ()
      ?clauses:*                // TODO: at least one should be required
    end
  } => { define generic ?enum-name ## "-name"
             (enum-instance :: "<" ## ?enum-name ## ">") => (n :: <string>);
         ignorable(?enum-name ## "-name");

         define class "<" ## ?enum-name ## ">" (<object>)
             constant slot ?enum-name ## "-name" :: <string>, required-init-keyword: name:;
         end;

         define enum-constants "<" ## ?enum-name ## ">", ?clauses end;
       }
end macro;

define macro enum-constants-definer
  { define enum-constants ?class:name end } => { }

  { define enum-constants ?class:name, ?:name;
      ?more:* 
    end }
    => { define constant ?name :: ?class = make(?class, name: ?"name");
         define enum-constants ?class, ?more end;
       }
end macro;
