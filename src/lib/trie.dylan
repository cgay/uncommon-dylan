Module: uncommon-utils-impl


// TODO: Open Dylan should export <invalid-index-error> (but named <invalid-key-error>)
// and we should subclass that.
define class <trie-element-error> (<simple-error>) end;

define function trie-element-error (format-string :: <string>, #rest args)
  signal(make(<trie-element-error>,
              format-string: format-string,
              format-arguments: args))
end function;


//// API

// The API consists of the exported classes, the generic functions defined here, and the
// collection protocol methods element, element-setter, key-test, size, and remove-key!.
// The forward-iteration-protocol implementation is very inefficient; generally use
// traverse instead.

// Find a node with the given key (i.e., path) anywhere in the trie.
// Compare to `element`, which retrieves a node's value.
define sealed generic find-node
    (node :: <trie-node>, key :: <seq>) => (node :: <trie-node?>);

// Access a local child node. This gives subclassers the opportunity to modify the key
// before lookup. For example, making lookup by character ignore case.
define open generic child-node
    (node :: <trie-node>, key) => (child :: <trie-node?>);

define open generic child-node-setter
    (new-value, node :: <trie-node>, key) => (new-value);

define open generic node-value
    (node :: <trie-node>) => (value);

define sealed generic traverse
    (fn :: <func>, node :: <trie-node>, #key keys? :: <bool>) => ();


define open abstract class <trie-node> (<object>)
  // Possible optimization: use a list of pairs initially and change to table after N
  // elements, on the theory that most nodes will have a low branch factor.
  constant slot %children :: <table> = make(<table>, size: 5),
    init-keyword: children:;

  // The object stored at this level in the trie, if any.
  slot %value :: <object> = $unsupplied,
    init-keyword: value:;
end class;

define method make (class == <trie-node>, #rest args, #key) => (trie :: <trie-node>)
  apply(next-method, <object-trie-node>, args)
end method;

define constant <trie-node?> = false-or(<trie-node>);

define method node-value (node :: <trie-node>) => (value)
  node.%value
end method;

define method child-node (node :: <trie-node>, key) => (child :: <trie-node?>)
  element(node.%children, key, default: #f)
end method;

define method child-node-setter
    (new-value, node :: <trie-node>, key) => (new-value)
  node.%children[key] := new-value
end method;

// Note that a <trie> is a <trie-node> and the empty sequence is the key that can
// retrieve its value.
define open abstract class <trie> (<mutable-explicit-key-collection>, <stretchy-collection>)
  constant slot %node-class :: <class> = <object-trie-node>,
    init-keyword: node-class:;
  slot %node-count :: <int> = 1;  // How many nodes in the tree?
  slot %value-count :: <int> = 0; // How many values are stored in the tree?
end class;

define method make (class == <trie>, #rest args, #key) => (trie :: <trie>)
  apply(next-method, <object-trie>, args)
end method;

define method initialize (trie :: <trie>, #key) => ()
  next-method();
  if (supplied?(trie.%value))
    inc!(trie.%value-count);
  end;
  for (child in trie.%children)
    inc!(trie.%value-count, child.%value-count);
    inc!(trie.%node-count, child.%node-count);
  end;
end method;

define method size (trie :: <trie>) => (#rest objects)
  values(trie.%value-count, trie.%node-count)
end method;

define method find-node
    (node :: <trie-node>, key :: <seq>) => (node :: <trie-node?>)
  let len :: <int> = key.size;
  iterate loop (node = node, i = 0)
    if (i == len)
      node              // Note that an empty key may return the root node.
    else
      let k = key[i];
      let child :: <trie-node?> = child-node(node, k);
      iff(child,
          loop(child, i + 1))
    end
  end iterate
end method;

define method find-node
    (node :: <trie-node>, key :: <list>) => (node :: <trie-node?>)
  iterate loop (node = node, key = key)
    if (key.empty?)
      node
    else
      let k = key.head;
      let child :: <trie-node?> = child-node(node, k);
      iff(child,
          loop(child, key.tail))
    end
  end iterate
end method;

define method element
    (trie :: <trie>, key :: <seq>, #key default = $unsupplied)
 => (element :: <object>)
  let node :: <trie-node?> = find-node(trie, key);
  if (~node)
    iff(supplied?(default),
        default,
        trie-element-error("element not found for key %=", key))
  else
    iff(supplied?(node.%value),
        node.%value,
        iff(supplied?(default),
            default,
            trie-element-error("element not found for key %=", key)))
  end
end method;

define method element-setter
    (new-value, trie :: <trie>, key :: <seq>) => (new-value :: <object>)
  let len :: <int> = key.size;
  iterate loop (node = trie, i = 0)
    if (i == len)
      if (~supplied?(node.%value)) // only increment if no value stored yet
        inc!(trie.%value-count);
      end;
      node.%value := new-value
    else
      let k = key[i];
      let child :: <trie-node?> = child-node(node, k);
      if (~child)
        child := (child-node(node, k) := make(trie.%node-class));
        inc!(trie.%node-count);
      end;
      loop(child, i + 1)
    end
  end iterate
end method;

// Optimization for list keys.
define method element-setter
    (new-value, trie :: <trie>, key :: <list>) => (new-value :: <object>)
  iterate loop (node = trie, key = key, i = 0)
    if (key.empty?)
      if (~supplied?(node.%value)) // only increment if no value stored yet
        inc!(node.%value-count);
        inc!(trie.%value-count);
      end;
      node.%value := new-value
    else
      let k = key.head;
      let child :: <trie-node?> = child-node(node, k);
      if (~child)
        child := (child-node(node, k) := make(trie.%node-class));
        inc!(trie.%node-count);
      end;
      loop(child, key.tail, i + 1)
    end
  end iterate
end method;

// Removing a key simply sets the node value to $unsupplied, it does not remove any
// nodes. (This can be changed but doesn't seem important for now.)
define method remove-key! (trie :: <trie>, key :: <seq>) => (removed? :: <bool>)
  let node = find-node(trie, key);
  if (node & supplied?(node.%value))
    node.%value := $unsupplied;
    #t
  end
end method;

// Traverse the entire Trie under `node`, executing fn(node, depth) for each node with a
// value. If keys? is true then execute fn(node, deptth, key) for each node with a
// value. The latter can be expensive since it requires creating a sequence for each key.
// The node is passed rather than the value itself so that extra data stored in node
// subclasses can be accessed.
define method traverse
    (fn :: <func>, node :: <trie-node>, #key keys? :: <bool>) => ()
  if (keys?)
    iterate loop-with-keys (node = node, key = #(), depth = 0)
      if (supplied?(node.%value))
        fn(node, depth, reverse(key));
      end;
      for (child keyed-by k in node.%children)
        loop-with-keys(child, pair(k, key), depth + 1);
      end;
    end;
  else
    iterate loop (node = node, depth = 0)
      if (supplied?(node.%value))
        fn(node, depth);
      end;
      for (child in node.%children)
        loop(child, depth + 1)
      end;
    end;
  end;
end method;

// This is a silly implementation. Use traverse instead if performance is an issue.
define method forward-iteration-protocol
    (trie :: <trie>)
 => (initial-state          :: <object>,
     limit                  :: <object>,
     next-state             :: <function>,
     finished-state?        :: <function>,
     current-key            :: <function>,
     current-element        :: <function>,
     current-element-setter :: <function>,
     copy-state             :: <function>)
  let v = make(<vector>, size: trie.size);
  let i = -1;
  traverse(method (node, _, key)
             v[inc!(i)] := pair(key, node.%value);
           end,
           trie, keys?: #t);
  local
    method next-state      (c, state)        state + 1     end,
    method finished-state? (c, state, limit) state = limit end,
    method current-key     (c, state)        v[state].head end,
    method current-element (c, state)        v[state].tail end,
    method current-element-setter (new-value, c, state)
      error("current-element-setter not implemented for <trie>s");
    end,
    method copy-state (state) state end;
  values(0,
         v.size,
         next-state,
         finished-state?,
         current-key,
         current-element,
         current-element-setter,
         copy-state)
end method;


//// <object-trie>

define class <object-trie-node> (<trie-node>)
end class;

// Keys are any kind of sequence whose elements are compared with ==, values are any
// object.
define class <object-trie> (<trie-node>, <trie>)
  keyword node-class: = <object-trie-node>;
end class;

define method key-test (trie :: <object-trie>) => (f :: <func>)
  \==
end method;


//// <ichar-trie> - case-insensitive character trie (i.e., keys are strings and each char
////                is compare case-insensitively).

define class <ichar-trie-node> (<trie-node>)
end class;

define class <ichar-trie> (<ichar-trie-node>, <trie>)
  keyword node-class: = <ichar-trie-node>;
end class;

define method child-node
    (node :: <ichar-trie-node>, key :: <char>) => (child :: <trie-node?>)
  element(node.%children, as-lowercase(key), default: #f)
end method;

define method child-node-setter
    (new-value, node :: <ichar-trie-node>, key :: <char>) => (new-value)
  node.%children[as-lowercase(key)] := new-value
end method;

define method key-test (trie :: <ichar-trie>) => (f :: <func>)
  method (k1, k2)
    k1 == k2 | (instance?(k1, <char>)
                  & instance?(k2, <char>)
                  & as-lowercase(k1) == as-lowercase(k2))
  end
end method;


//// <string-trie>

// <trie>s whose keys are sequences of strings compared case sensitively.

define class <string-trie-node> (<trie-node>)
  keyword children: = make(<string-table>, size: 5);
end class;

define class <string-trie> (<string-trie-node>, <trie>)
  keyword children: = make(<string-table>, size: 5);
  keyword node-class: = <string-trie-node>;
end class;

// This is not used internally because key equality is implemented by using a certain
// type of <table> for %node-children (at least for now), but this method is technically
// required to be implmented or inherited for all collections.
define method key-test (trie :: <string-trie>) => (f :: <func>)
  \=
end method;


//// <istring-trie>

// <trie>s whose keys are sequences of strings compared case sensitively.

define class <istring-trie-node> (<trie-node>)
  keyword children: = make(<istring-table>, size: 5);
 end class;

define class <istring-trie> (<istring-trie-node>, <trie>)
  keyword children: = make(<istring-table>, size: 5);
  keyword node-class: = <istring-trie-node>;
end class;

// This is not used internally because key equality is implemented by using a certain
// type of <table> for %node-children (at least for now), but this method is technically
// required to be implmented or inherited for all collections.
define method key-test (trie :: <istring-trie>) => (f :: <func>)
  local
    method istring= (s1, s2)
      let len = s1.size;
      s2.size == len
        & iterate loop (i = 0)
            iff(i == len,
                #t,
                iff(as-lowercase(s1[i]) == as-lowercase(s2[i]),
                    loop(i + 1),
                    #f))
          end
    end;
  method (k1, k2)
    k1 == k2
      | (instance?(k1, <seq>)
           & instance?(k2, <seq>)
           & (k1.size == k2.size)
           & block (return)
               for (s1 in k1, s2 in k2)
                 if (~istring=(s1, s2))
                   return(#f)
                 end;
               end;
               #t
             end)
  end method
end method;
