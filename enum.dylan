Module: uncommon-utils-internal

// A simple 'define enum' macro that provides
//   * a type to dispatch on
//   * a set of module constants of that type
//   * a name and numeric value associated with each constant
//   * no need to use symbols, which
//      - are a leaky abstraction
//      - can be misspelled without causing a warning
//      - don't generate cross references

// We rely on the compiler to generate warnings for duplicate enum clause names
// since each clause defines its own constant.

// Examples:
//
// Simplest form:
//
//   define enum <test-result> ()
//     $passed; $failed; $skipped; $error;
//   end;
//   assert-equal(test-result-name($passed), "$passed");
//   assert-equal(test-result-value($passed), 1);
//   assert-equal(test-result-value($error), 4);
//
// With more options. Note that if you need for the values to remain constant
// across addition/removal of enum values you may assign a specific value:
//
//   define enum <test-result> (strip-prefix: "$color-")
//     $color-red;
//     $color-green = 4;
//     ...
//   end;
//   assert-equal(test-result-name($color-red), "red");  // "$color-" stripped from name
//   assert-equal(test-result-value($color-red), 1);
//
// Duplication of names or values is an error:
//
//   define enum <e> () $x; $x; end           // error
//   define enum <e> () $x = 1; $y = 1; end   // error

define macro enum-definer
  { define enum "<" ## ?enum-name:name ## ">" ()
      ?clauses:*
    end
  } => { define sealed generic ?enum-name ## "-name"
             (enum-instance :: "<" ## ?enum-name ## ">") => (name :: <string>);
         define sealed generic ?enum-name ## "-value"
             (enum-instance :: "<" ## ?enum-name ## ">") => (value :: <int>);
         ignorable(?enum-name ## "-name");
         ignorable(?enum-name ## "-value");

         define class "<" ## ?enum-name ## ">" (<object>)
             constant slot ?enum-name ## "-name" :: <string>, required-init-keyword: name:;
             constant slot ?enum-name ## "-value" :: <int>, required-init-keyword: value:;
         end;

         define enum-constants "<" ## ?enum-name ## ">", 1, ?clauses end;
       }
end macro;

define macro enum-constants-definer
  { define enum-constants ?class:name, ?value:expression end } => { }

  { define enum-constants ?class:name, ?value:expression, ?:name;
      ?more:* 
    end }
    => { define constant ?name :: ?class = make(?class, name: ?"name", value: ?value);
         define enum-constants ?class, ?value + 1, ?more end;
       }
end macro;
