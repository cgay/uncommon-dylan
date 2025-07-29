Module: uncommon-utils-internal

//// Tries whose keys are strings

// Not nearly ready for prime time but basically works.

// TODO: shouldn't be specific to strings.
// TODO: should have forward-iteration-protocol method.

// TODO: should subclass <explicit-key-collection>
define class <string-trie> (<object>)
  constant slot trie-children :: <string-table>,
    init-function: curry(make, <string-table>);
  slot trie-object :: <object>,
    required-init-keyword: object:;
end;

define class <trie-error> (<format-string-condition>, <error>)
end;

// TODO: should just be element-setter
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

// TODO: should be remove-key!.
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
// TODO: should be element method. But can it still return extra values?
// If that's really useful, could also have separate lookup method.
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
