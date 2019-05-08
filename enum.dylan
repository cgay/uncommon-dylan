Module: uncommon-utils

// ----------------------------------------------------------------------
/*
// Simplest case, no values specified.
// Constant names are fully-specified. It's a little more verbose than some
// enums but there are no surprises.
define enum <error-code> ()
    $parse-error;               // values start at 1
    $foo-error;                 // 2
    $bar-error;                 // 3
end;

define enum <error-code> ()
    $unknown-error = 0;         // Explicitly set 0 as first. a nod to protobufs.
    $parse-error;               // 1
    $foo-error;                 // 2
    $bar-error = 5;             // 5
    $baz-error;                 // 6
end;

==>>

define concrete class <error-code> (<enum>)
  each-subclass slot by-value :: <table> = make(<table>);
end;

define method initialize (enum :: <error-code>) => (@@)
  enum.value-to-instance[enum-value(enum)]
  := enum;
end;

define constant $parse-error :: <error-code>
  = make(<error-code>, description: "parse error", value: 1);
define constant $parse-error :: <error-code>
  = make(<error-code>, description: "the fooest error", value: 20);
define constant $unknown-error :: <error-code>
  = make(<error-code>, description: "unknown error", value: 21);

*/
/* for now

// TODO: Good chance this isn't the best API or most efficient implementation. Mostly
// working on the surface syntax for now and will come back to the implementation.
define open class <enum> (<object>)
  // TODO: how can this be made "constant slot enum-value :: <int>"?
  slot enum-value :: <int>?,
    required-init-keyword: value:;
  constant slot enum-description :: <string>,
    required-init-keyword: description:;

  // Maps from the enum value to the enum instance.
  constant each-subclass slot by-value :: <table> = make(<table>);
end;


// Not thread safe, but should always be invoked at load time by "define enum".
define method make
    (class :: subclass(<enum>), #rest args, #key value :: <uint>, description :: <string>)
 => (e :: <enum>)
  if (~value)
    // Assign the next highest value to this instance.
    let next = #f;
    for (_ keyed-by k in class.by-value)
      next := iff(next, max(next, k), k);
    end;
    next := iff(next, next + 1, 1);
    enum.enum-value := next;
    value := next;
  end;
  if (element(enum.value-to-enum, value, default: #f))
    error("value %d is used more than once in %s enum", enum.object-class);
  end;
  let enum = apply(next-method, value: value, description: description, args);
  enum.value-to-enum[v] := enum
end;

define macro enum-definer
    { define enum "<" ## ?enum-class:name ## ">" (/* for future expansion */) ?clauses:* end }
 => { define class "<" ## ?enum-class ## ">" (<enum>) end; 
      define method initialize
          (enum :: "<" ## ?enum-class ## ">" , #next next-method, #rest args, #key value) => ()
        next-method();
        enum.value-to-enum[value] := enum;
      end;
      define enum-constants ?enum-class ?clauses end;
    }
end;

define macro enum-constants-definer
  { define enum-constants ?enum-class:name end }
    => { }

  // just a name
  { define enum-constants ?enum-class:name ?:name ; ?more:* end }
    => { define enum-constants ?enum-class ?name = #f, ?"name"; ?more end }

  // just name = value, generate a default description
  { define enum-constants ?enum-class:name ?:name = ?value:expression ; ?more:* end }
    => { define enum-constants ?enum-class
           // TODO: try this with implicit string concatenation instead of calling concat.
           ?name = ?value, concat(?"name", " :: <", ?"enum-class", ">");
           ?more
         end }

  // just name, description -- generate a value
  { define enum-constants ?enum-class:name ?:name , ?description:expression ; ?more:* end }
    => { define enum-constants ?enum-class ?name = #f, ?description; ?more end }

  // name = value, description;
  { define enum-constants ?enum-class:name ?:name = ?value:expression , ?description:expression ; ?more:* end }
    => { define constant ?name :: "<" ## ?enum-class ## ">"
           = make("<" ## ?enum-class ## ">", value: ?value, description: ?description);
         define enum-constants ?enum-class ?more end;
       }
end macro;


*/
