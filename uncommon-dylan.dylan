Module:   uncommon-utils
Synopsis: Some definitions of general use that could be considered for
          inclusion in common-dylan if they stand the test of time.
Copyright: See LICENSE in this distribution for details.


// ----------------------------------------------------------------------
// Simple type defs

define constant <int*> = limited(<int>, min: 0);
define constant <int+> = limited(<int>, min: 1);


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
    end }
    => { block ()
           ?body
         exception (?condition, init-arguments: vector(?initargs))
           values(#f, #t)
         end }
end macro with-restart;

// with-simple-restart("Retry opening file") ... end
//
define macro with-simple-restart
  { with-simple-restart (?format-string:expression, ?format-args:*)
      ?:body
    end }
    => { with-restart (<simple-restart>,
                       format-string: ?format-string,
                       format-arguments: vector(?format-args))
           ?body
         end }
end macro with-simple-restart;

// ----------------------------------------------------------------------
/*
define class <enum> (<object>)
  slot enum-value :: <integer>, required-init-keyword: value:;
  slot enum-description :: <string>, init-keyword: description:;
end;

define enum <error-code> ()
  $parse-error, "parse error";  // first value = 1 by default
  20, $foo-error, "the fooest error"; // value = 20
  $unknown, "unknown error";    // value = 21, starts from previous
end;
=>

define class <error-code> (<enum>)
  class slot value-to-instance :: <table> = make(<table>);
end;

define method initialize (enum :: <error-code>) => ()
  enum.value-to-instance[enum-value(enum)] := enum;
end;

define constant $parse-error :: <error-code>
  = make(<error-code>, description: "parse error", value: 1);
define constant $parse-error :: <error-code>
  = make(<error-code>, description: "the fooest error", value: 20);
define constant $unknown-error :: <error-code>
  = make(<error-code>, description: "unknown error", value: 21);

*/

define open class <enum> (<object>)
  constant slot enum-value :: <int>, required-init-keyword: value:;
  constant slot enum-description :: <string>, init-keyword: description:;
  constant each-subclass slot value-to-enum :: <table> = make(<table>);
end;

define macro enum-definer
  { define enum ?enum-class:name (/* for future expansion */) ?clauses:* end }
    => { define class ?enum-class (<enum>) end; 
         define method initialize (enum :: ?enum-class, #next next-method, #rest args, #key value) => ()
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
  // just name = value
  { define enum-constants ?enum-class:name ?:name = ?value:expression ; ?more:* end }
    => { define enum-constants ?enum-class ?name = ?value, ?"name"; ?more end }
  // just name, description
  { define enum-constants ?enum-class:name ?:name , ?description:expression ; ?more:* end }
    => { define enum-constants ?enum-class ?name = #f, ?description; ?more end }
  // full form: name = value, description;
  { define enum-constants ?enum-class:name ?:name = ?value:expression , ?description:expression ; ?more:* end }
    => { define constant ?name :: ?enum-class
           = make(?enum-class, value: ?value, description: ?description);
         define enum-constants ?enum-class ?more end;
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
// Convert a string to a floating point number.
// This version is from Chris Double's dylanlibs project, and
// seems to be the most precise of the three.  I renamed it
// from formatted-string-to-float to string-to-float.  I added
// min(..., 7) in a couple places as a quick kludge to keep from
// getting integer overflow errors.  Should figure out the right
// way...  -cgay
//
define method string-to-float(s :: <string>) => (f :: <float>)
  local method is-digit?(ch :: <char>) => (b :: <bool>)
    let v = as(<int>, ch);
    v >= as(<int>, '0') & v <= as(<int>, '9');
  end method;
  let lhs = make(<stretchy-vector>);
  let rhs = make(<stretchy-vector>);
  let state = #"start";
  let sign = 1;

  local method process-char(ch :: <char>)
    select (state)
      #"start" =>
        select (ch)
          '-' =>
            begin
              sign := -1;
              state := #"lhs";
            end;
          '+' =>
            begin
              sign := 1;
              state := #"lhs";
            end;
          '.' =>
            begin
              lhs := add!(lhs, '0');
              state := #"rhs";
            end;
          otherwise =>
            begin
              state := #"lhs";
              process-char(ch);
            end;
        end select;
      #"lhs" =>
        case
          is-digit?(ch) => lhs := add!(lhs, ch);
          ch == '.' => state := #"rhs";
          otherwise => error("Invalid floating point value.");
        end case;
      #"rhs" =>
        case
          is-digit?(ch) => rhs := add!(rhs, ch);
          otherwise => error("Invalid floating point value.");
        end case;
      otherwise => error("Invalid state while parsing floating point.");
    end select;
  end method;

  for (ch in s)
    process-char(ch);
  end for;

  let lhs = as(<string>, lhs);
  let rhs = iff(empty?(rhs), "0", as(<string>, rhs));
  (string-to-integer(lhs) * sign)
   + as(<double-float>, string-to-integer(rhs) * sign)
     / (10 ^ min(rhs.size, 7));
end method string-to-float;

// Convert a floating point to a string without the Dylan specific formatting.
// Prints to the given number of decimal places.
// Written by Chris Double, as part of dylanlibs.
//
define method float-to-formatted-string
    (value :: <float>, #key decimal-places)
 => (s :: <string>)
  let value = iff(decimal-places,
                  as(<double-float>, truncate(value * 10 ^ min(decimal-places, 7))) / 10d0 ^ decimal-places,
                  value);
  let s = float-to-string(value);
  let dp = subsequence-position(s, ".");
  let tp = subsequence-position(s, "d") | subsequence-position(s, "s") | s.size;
  let lhs = slice(s, 0, dp);
  let rhs = slice(s, dp + 1, tp);
  let shift = if (tp = s.size) 0  else string-to-integer(s, start: tp + 1) end;
  let result = "";
  let temp = concat(lhs, rhs);
  let d = lhs.size - 1 + shift;
  if (shift < 0)
    for (n from 0 below abs(shift))
      temp := concat("0", temp);
    end for;
    d := 0;
  elseif (shift > 0)
    for (n from 0 below shift)
      temp := concat(temp, "0");
    end for;
    d := temp.size;
  end if;

  let tsize = temp.size;
  concat(slice(temp, 0, min(d + 1, tsize)),
         iff(d = tsize, "", "."),
         iff(d = tsize,
             "",
             slice(temp,
                   d + 1,
                   iff(decimal-places,
                       min(d + 1 + decimal-places, tsize),
                       tsize))));
end method float-to-formatted-string;


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
    (collection :: <collection>, predicate :: <func>,
     #key limit :: false-or(<int>))
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

//// Tries who's keys are strings

// TODO: shouldn't be specific to strings.
// TODO: should have forward-iteration-protocol method.

define class <string-trie> (<object>)
  constant slot trie-children :: <string-table>,
    init-function: curry(make, <string-table>);
  slot trie-object :: <object>,
    required-init-keyword: object:;
end;

define class <trie-error> (<format-string-condition>, <error>)
end;

define method add-object
    (trie :: <string-trie>, path :: <seq>, object :: <object>,
     #key replace?)
 => ()
  local method real-add (trie, rest-path)
          if (rest-path.size = 0)
            if (trie.trie-object = #f | replace?)
              trie.trie-object := object;
            else
              signal(make(<trie-error>,
                          format-string: "Trie already contains an object for the "
                                         "given path (%=).",
                          format-arguments: list(path)));
            end if;
          else
            let first-path = rest-path[0];
            let other-path = slice(rest-path, 1, #f);
            let children = trie-children(trie);
            let child = element(children, first-path, default: #f);
            unless (child)
              let node = make(<string-trie>, object: #f);
              children[first-path] := node;
              child := node;
            end;
            real-add(child, other-path)
          end;
        end method real-add;
  real-add(trie, path)
end method add-object;

define method remove-object
    (trie :: <string-trie>, path :: <seq>)
 => ()
  let nodes = #[];
  let node = reduce(method (a, b)
                      nodes := add!(nodes, a);
                      a.trie-children[b]
                    end,
                    trie, path);
  let object = node.trie-object;
  node.trie-object := #f;
  block (stop)
    for (node in reverse(nodes), child in reverse(path))
      if (size(node.trie-children[child].trie-children) = 0 & ~node.trie-object)
        remove-key!(node.trie-children, child);
      else
        stop()
      end if;
    end for;
  end;
  object
end method remove-object;

// Find the object with the longest path, if any.
// 2nd return value is the path that matched.
// 3rd return value is the part of the path that
// came after where the object matched.
//
define method find-object
    (trie :: <string-trie>, path :: <seq>)
 => (object :: <object>, rest-path :: <seq>, prefix-path :: <seq>)
  local method real-find (trie, path, object, prefix, rest)
          if (empty?(path))
            values(object, rest, reverse(prefix))
          else
            let child = element(trie.trie-children, head(path), default: #f);
            if (child)
              real-find(child, tail(path), child.trie-object | object,
                        pair(head(path), prefix),
                        iff(child.trie-object, tail(path), rest));
            else
              values(object, rest, reverse(prefix));
            end
          end
        end method real-find;
  real-find(trie, as(<list>, path), trie.trie-object, #(), #());
end method find-object;


//// Collection functions

// TODO: slice! and slice!-setter ?

define method slice
    (seq :: <seq>, bpos :: <int*>, epos :: false-or(<int*>))
 => (slice :: <seq>)
  copy-sequence(seq, start: bpos, end: epos | seq.size)
end;

// One of my least favorite things in Dylan is having to switch from
// c[i] syntax to element(c, i, default: d) just because there's a
// rare case where the collection may contain #f. "elt" is perhaps
// short enough that I can just use it all the time instead of c[i]
// syntax. That's the problem I would like to solve.
//   elt(collection, key, or: default)
define macro elt
  { elt(?c:expression, ?k:expression, #key ?or:expression) }
    =>
  { element(?c, ?k, default: ?or) }
end;

// I'm leaving this here as a reminder to myself. Is there a better
// name?
define function err
    (class :: <class>, message, #rest args)
  error(make(class, format-string: message, format-arguments: args));
end;
