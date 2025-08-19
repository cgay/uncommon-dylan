Module: uncommon-utils-impl


// Traditional integer-based enums.
//
// Example:
// define enum color ()
//   $color-red;                // defines $color-red   :: <int> = 1  with name "$color-red"
//   $color-green = 20;         // defines $color-green :: <int> = 20 with name "$color-green"
//   $color-blue        "Blue"; // defines $color-blue  :: <int> = 21 with name "Blue"
//   $color-cyan = 30   "Cyan"; // defines $color-cyan  :: <int> = 30 with name "Cyan"
// end;
//
// Two additional constants are defined:
//   $color-names  => #["$color-red", "$color-green", "Blue", "Cyan"]
//   $color-values => #[1, 20, 21, 30]
// The elements are in the order in which they appear in the enum.

// TODO: I was unable to make a `prefix: "$color-"` option work because it doesn't seem
// possible to concatenate two NAME tokens into a single NAME using ##.

define macro enum-definer
    { define enum ?enum-name:name () ?clauses:* end }
 => { ?@defconst{ 1 ; ?clauses }
      define constant "$" ## ?enum-name ## "-names" = vector(?@pretty-names{ ?clauses });
      define constant "$" ## ?enum-name ## "-values" = vector(?@constant-names{ ?clauses });
      define constant ?enum-name ## "-to-name"
        = curry(enum-value-to-name, "$" ## ?enum-name ## "-names", "$" ## ?enum-name ## "-values");
      define constant "name-to-" ## ?enum-name
        = curry(enum-name-to-value, "$" ## ?enum-name ## "-names", "$" ## ?enum-name ## "-values");
      ignorable("$" ## ?enum-name ## "-values",
                "$" ## ?enum-name ## "-names",
                ?enum-name ## "-to-name",
                "name-to-" ## ?enum-name);
    }

 defconst:
    { ?default:expression } => { }

    // Rewrite foo; => foo = default ("foo");
    { ?default:expression ; ?:name ; ?more:* }
 => { ?@defconst{ ?default ; ?name = ?default ?"name" ; ?more } }

    // Rewrite foo = 1; => foo = 1 ("foo");
    { ?default:expression ; ?:name = ?value:expression ; ?more:* }
 => { ?@defconst{ ?value + 1 ; ?name = ?value ?"name" ; ?more } }

    // Rewrite foo ("Foo"); => foo = default ("Foo");
    { ?default:expression ; ?:name ?pretty-name:expression ; ?more:* }
 => { ?@defconst{ ?default ; ?name = ?default ?pretty-name ; ?more } }

    // Fully specified case
    { ?default:expression ; ?:name = ?value:expression ?pretty-name:expression ; ?more:* }
 => { define constant ?name :: <int> = ?value;
      ?@defconst{ ?value + 1 ; ?more } }

 constant-names:
    { } => {}
    { ?:name ?junk:* ; ...} => { ?name , ... }

 pretty-names:
    { ?:name = ?:expression ?pretty-name:expression ; ... } => { ?pretty-name , ... }
    { ?:name ?pretty-name:expression ; ... }                => { ?pretty-name , ... }
    { ?:name = ?:expression ; ... }                         => { ?"name" , ... }
    { ?:name ; ... }                                        => { ?"name" , ... }
    {} => {}
end macro;

define function enum-value-to-name
    (enum-names :: <seq>, enum-values :: <seq>, item-value :: <int>) => (name :: <string?>)
  block (return)
    for (name in enum-names,
         value in enum-values)
      if (value == item-value)
        return(name)
      end
    end
  end
end function;

define function enum-name-to-value
    (enum-names :: <seq>, enum-values :: <seq>, item-name :: <string>) => (value :: <int?>)
  block (return)
    for (name in enum-names,
         value in enum-values)
      if (name = item-name)
        return(value)
      end
    end
  end
end function;



// ---------------------------------------------------------------
// Class-based enums. Example:
//
// define enum-class <planet> ()
//   constant slot %name :: <string>, required-init-keyword: name:;
//   constant slot %mass :: <float>,  required-init-keyword: mass:;
//   $mercury (name: "Mercury", mass: 1.1);
//   $venus   (name: "Venus",   mass: 3.3);
//   $mars    (name: "Mars",    mass: 5.5);
// end;
//
// $planet-instances => vector($mercury, $venus, $mars)
//
// We assume that if a value <-> name mapping is needed, it can easily be implemented by
// the caller via $planet-instances.

define macro enum-class-definer
    { define enum-class "<" ## ?enum-name:name ## ">" (?supers:*) ?clauses:* end }
 => { define class "<" ## ?enum-name ## ">" (?supers)
        ?@slots{ ?clauses }
      end;
      ?@defconst{ "<" ## ?enum-name ## ">" ; ?clauses }
      define constant "$" ## ?enum-name ## "-instances" :: <seq>
        = vector(?@constant-names{ ?enum-name ; ?clauses });
    }

 slots:
   {} => {}
   { ?adjectives:* slot ?more:* ; ... } => { ?adjectives slot ?more ; ... }
   { ?:name ( ?initargs:* )     ; ... } => { ... }

 defconst:
     { ?enum-class:name } => {}

     { ?enum-class:name ; ?adjectives:* slot ?more-slot:* ; ?more:* }
  => { ?@defconst{ ?enum-class ; ?more } }

     { ?enum-class:name ; ?:name ( ?initargs:* ) ; ?more:* }
  => { define constant ?name :: ?enum-class = make(?enum-class, ?initargs);
       ?@defconst{ ?enum-class ; ?more }
     }

 constant-names:
     { ?enum-name:name } => {}

     { ?enum-name:name ; ?adjectives:* slot ?more-slot:* ; ?more:* }
  => { ?@constant-names{ ?enum-name ; ?more } }

     // For reasons I don't quite grok, the last clause has to be handled specially to
     // avoid a trailing comma in the expansion.
     { ?enum-name:name ; ?:name ( ?initargs:* ) ; }
  => { ?name }

     { ?enum-name:name ; ?:name ( ?initargs:* ) ; ?more:* }
  => { ?name , ?@constant-names{ ?enum-name ; ?more } }

 adjectives:
   {}             => {}
   { ?:name ... } => { ?name ... }
end macro;
