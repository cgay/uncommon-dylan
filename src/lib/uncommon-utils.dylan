Module: uncommon-utils-impl


// ----------------------------------------------------------------------

// Similar to definitions in brevity.dylan, but for which there are no equivalents in the
// common-dylan module.

define constant <uint>    = limited(<int>, min: 0);
define constant <uint?>   = false-or(<uint>);
define function uint? (object) => (bool :: <bool>) instance?(object, <uint>) end;

define constant <istring-table> = <case-insensitive-string-table>;

// ----------------------------------------------------------------------

// Like prog1 in Common lisp, return the value of the first expression.
define macro begin1
    { begin1 ?exp1:expression ?:body end }
 => { let result = ?exp1; ?body; result }
end macro;

// ----------------------------------------------------------------------

// `iff` is a replacement for `if` expressions which reduces verbosity and increases
// readability compared to the built-in `if` statement when used for very short
// conditionals.  Essentially it removes the need for the `else` and `end` lines of a
// standard `if` when spread across multiple lines, and increases readability compared to
// standard `if` when on one line.  (This is all, of course, a matter of opinion.)
//
// Instead of this:
//   if (test)
//     something()
//   else
//     something-else()
//   end
// write this with iff:
//   iff(test, something(), something-else())
// or if the true/false parts are longer,
//   iff(test,
//       something-or-other(),
//       something-else-or-other())
//
define macro iff
    { iff(?test:expression, ?true:expression, ?false:expression) }
 => { if (?test) ?true else ?false end }

    { iff(?test:expression, ?true:expression) }
 => { if (?test) ?true end }
end macro;

// ----------------------------------------------------------------------
define macro with-restart
    { with-restart (?condition:expression, #rest ?initargs:*)
        ?:body
      end
    }
 => { block ()
        ?body
      exception (?condition, init-arguments: vector(?initargs))
        values(#f, #t)
      end
    }
end macro with-restart;

// with-simple-restart("Retry opening file") ... end
//
define macro with-simple-restart
    { with-simple-restart (?format-string:expression, ?format-args:*)
        ?:body
      end
    }
 => { with-restart (<simple-restart>,
                    format-string: ?format-string,
                    format-arguments: vector(?format-args))
        ?body
      end
    }
end macro;

// ----------------------------------------------------------------------
// define class <my-class> (<singleton-object>) ... end
//
define open abstract class <singleton-object> (<object>)
end;

// Maps classes to their singleton instances.
define constant $singletons :: <table> = make(<table>);

define method make
    (class :: subclass(<singleton-object>), #rest args, #key)
 => (object :: <singleton-object>)
  element($singletons, class, default: #f)
  | begin
      $singletons[class] := next-method()
    end
end;


// ----------------------------------------------------------------------

define macro inc!
  { inc! (?place:expression, ?dx:expression) }
    => { ?place := ?place + ?dx; }
  { inc! (?place:expression) }
    => { ?place := ?place + 1; }
end macro inc!;

define macro dec!
  { dec! (?place:expression, ?dx:expression) }
    => { ?place := ?place - ?dx; }
  { dec! (?place:expression) }
    => { ?place := ?place - 1; }
end macro dec!;


// ----------------------------------------------------------------------
// ASH with explicit direction. Specifying direction via a negative count
// may be traditional but it's pretty opaque.
//
// (What about adding << and >> operators to Open Dylan?)

define inline function ash<<
    (i :: <int>, count :: <uint>) => (_ :: <int>)
  ash(i, count)
end function;

define inline function ash>>
    (i :: <int>, count :: <uint>) => (_ :: <int>)
  ash(i, - count)
end function;

// ----------------------------------------------------------------------
// Collections

// Count the number of occurrences of item in collection, as determined by the predicate.
// 'limit' is an efficiency hack: stop counting when limit is reached, the idea being
// that you might want to know if there's more than one of the given item.
define function count
    (collection :: <collection>, predicate :: <func>, #key limit :: <int?>)
 => (count :: <int>)
  let count :: <int> = 0;
  for (item in collection,
       while: ~limit | count < limit)
    if (predicate(item))
      inc!(count)
    end;
  end;
  count
end function;
