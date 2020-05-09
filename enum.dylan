Module: uncommon-utils

// A simple 'define enum' macro that provides
//   * a type to dispatch on
//   * a set of constants to reference
//   * automatic generation of consecutive numeric enum values
//   * a name associated with each enum value
//   * no need to use symbols (i.e., leaky abstraction)

// When I wrote this I had two use cases in mind:
//
//   1. The Dylan pattern of using a set of symbols like #"passed", #"failed",
//      #"skipped" for what in other languages would be an enum. Using symbols
//      like this creates a leaky abstraction which can result in developers or
//      users of the library using the symbols directly. You really want to at
//      least define a set of constants bound to the symbols, and use those
//      instead, so that you (a) get compile-time errors when you misspell the
//      name, (b) get cross references that make it easy to find what the
//      symbol represents in the code, and (c) can easily change the name of
//      the symbol in one place if that's necessary.
//
//      In addition to all that you're likely to want to define a type union
//      that includes all of the symbols so that you can dispatch on it.
//
//   2. Google protocol buffer enums. I've been playing with protobufs a lot
//      recently and I imagined this being used in a Dylan protobuf
//      implementation, which needs to map names <-> numbers. It's entirely
//      possible these should be two separate concerns.
//
// An implementation note...
//
// I wanted to make 'define enum' look like this:
//
//    define enum <result> () passed; failed; skipped; end
//
// rather than the current syntax:
//
//    define enum <result> () $result-passed; $result-failed; $result-skipped; end
//
// But it turns out that there's a limitation in Dylan macros that prevents the
// more concise syntax from working if I want the generated constant names to
// look like $result-foo: you can only use ## concatenation with
//
//    LITERAL-STRING ## NAME ## LITERAL-STRING
//
// and apparently only a maximum of two ##'s strung together, so this won't work:
//
//    "$" ## ?enum-class-name ## "-" ## ?enum-value-name
//
// I was unable to find a way to work around this.

define class <enum-error> (<error>) end;

define dynamic abstract class <enum> (<object>)
  // This slot is set to #f after the last instance is created since it's only
  // needed to detect duplicate values during initialization.
  constant each-subclass slot %used-values = make(<stretchy-vector>);
end;

// Signal <enum-error> if a value is used twice in one enum definition.
// No need to check whether names are used twice since the compiler will warn.
define method initialize (enum :: <enum>, #rest args, #key value :: <int>)
  next-method();
  if (member?(value, %used-values(enum)))
    error(make(<enum-error>,
               format-string: "Value %d used twice in enum %s",
               format-arguments: list(value, enum.object-class)))
  end;
  add!(%used-values(enum), value);
end method;

define macro enum-definer
  { define enum "<" ## ?enum-name:name ## ">" () // TODO: allow names without <>
      ?clauses:*                // TODO: at least one should be required
    end
  } => { define generic ?enum-name ## "-value"
             (enum-instance :: "<" ## ?enum-name ## ">") => (v :: <int>);
         define generic ?enum-name ## "-name"
             (enum-instance :: "<" ## ?enum-name ## ">") => (n :: <string>);
         ignorable(?enum-name ## "-name");

         define class "<" ## ?enum-name ## ">" (<enum>)
             constant slot ?enum-name ## "-value" :: <int>, required-init-keyword: value:;
             constant slot ?enum-name ## "-name" :: <string>, required-init-keyword: name:;
         end;

         define enum-constants "<" ## ?enum-name ## ">", 0, ?clauses end;
         // TODO: %clear-used-values(...)
       }
end macro;

define macro enum-constants-definer
  { define enum-constants ?class:name, ?max:expression end } => { }

  { define enum-constants ?class:name, ?max:expression, ?:name;
      ?more:* 
    end }
    => { define enum-constants ?class, ?max, ?name = ?max; ?more end }

  { define enum-constants ?class:name, ?max:expression, ?:name = ?value:expression ;
      ?more:*
    end }
    => { define constant ?name :: ?class = make(?class, value: ?value, name: ?"name");
         define enum-constants ?class, (?value + 1), ?more end;
       }
end macro;
