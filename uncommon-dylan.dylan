Module:   uncommon-dylan
Synopsis: Some definitions of general use that could be considered for
          inclusion in common-dylan if they stand the test of time.
Copyright: See LICENSE in this distribution for details.

// TODO(cgay): document the reasons why I think some of these (e.g., iff)
// are useful.

// ----------------------------------------------------------------------
// Simple type defs

define constant <uint>   = limited(<int>, min: 0);
define constant <int>? = false-or(<int>);
define constant <uint>? = false-or(<uint>);

// ----------------------------------------------------------------------
// iff(test, true-part)
// iff(test, true-part, false-part)
//
define macro iff
    { iff(?test:expression, ?true:expression, ?false:expression) }
 => { if (?test) ?true else ?false end }

    { iff(?test:expression, ?true:expression) }
 => { if (?test) ?true end }
end;


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


// TODO:
//   as(<int>, "123")
//   as(<single-float>, "123.0")
//   as(<double-float>, "123.0")
//   The equivalent works in Python, so why not Dylan?  The options
//   in string-to-integer, for example, are just difficult to program
//   around when you want to know if the string you have your hands on
//   can be converted to an integer.  Skipping initial whitespace feels
//   like featuritis.  I'm guessing it came from CL.
//
//   Semi-related, I would like all such built-in converters to raise
//   <value-error> (better name?) instead of just <error>.


// ----------------------------------------------------------------------
// For removing certain keyword/value pairs from argument lists before
// passing them along with apply or next-method.
//
define method remove-keys
    (arglist :: <seq>, #rest keys-to-remove) => (x :: <list>)
  let result :: <list> = #();
  let last-pair = #f;
  for (i from 0 below arglist.size by 2)
    let arg = arglist[i];
    if (~member?(arg, keys-to-remove))
      if (last-pair)
        let key-val = list(arg, arglist[i + 1]);
        tail(last-pair) := key-val;
        last-pair := tail(key-val);
      else
        result := list(arg, arglist[i + 1]);
        last-pair := tail(result);
      end;
    end;
  end;
  result
end method remove-keys;


// ----------------------------------------------------------------------
// Seems like this should be in the core language.
//
// TODO: handle standard prefixes for other radices: 0b, 0, 0x
// TODO: DON'T skip initial whitespace or allow other cruft at end,
//       like string-to-integer does.
// TODO: DO raise a better error type.
//
define sideways method as
    (type == <int>, value :: <string>) => (i :: <int>)
  string-to-integer(value)
end;

// ----------------------------------------------------------------------
// Collections

// A complement to key-sequence
define method value-sequence
    (collection :: <explicit-key-collection>) => (seq :: <seq>)
  let v :: <vector> = make(<vector>, size: collection.size);
  for (val keyed-by key in collection,
       i from 0)
    v[i] := val;
  end;
  v
end;

// copy-table? copy-table-as?

// Count the number of occurrences of item in collection, as determined
// by the predicate.  'limit' is an efficiency hack: stop counting when limit
// is reached, the theory being that it's common to want to know if there's
// more than one of the given item.
define open generic count
    (collection :: <collection>, predicate :: <func>, #key limit)
 => (count :: <int>);

define method count
    (collection :: <collection>, predicate :: <func>, #key limit :: <int>?)
 => (count :: <int>)
  let count :: <int> = 0;
  for (item in collection,
       while: ~limit | count < limit)
    if (predicate(item))
      inc!(count)
    end;
  end;
  count
end method count;

//// Collection functions

// TODO: slice! and slice!-setter ?
// TODO: make slice a macro so slice(s, b) and slice(s, b, e) work?
// TODO: write a dep for slice notation?  s[s:b] ?

define method slice
    (seq :: <seq>, bpos :: <uint>, epos :: <uint>?)
 => (slice :: <seq>)
  copy-sequence(seq, start: bpos, end: epos | seq.size)
end;
