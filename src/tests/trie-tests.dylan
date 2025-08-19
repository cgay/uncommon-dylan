Module: uncommon-dylan-test-suite


define test test-trie-root ()
  let t1 = make(<trie>);
  assert-equal(100, element(t1, "", default: 100));

  let (vals, nodes) = t1.size;
  assert-equal(0, vals);
  assert-equal(1, nodes);

  t1[""] := 200;
  assert-equal(200, t1[""]);

  let (vals, nodes) = t1.size;
  assert-equal(1, vals);
  assert-equal(1, nodes);

  let t2 = make(<trie>, value: 300);
  assert-equal(300, t2[""]);
end test;

define test test-trie-add-remove ()
  let t1 = make(<trie>);
  assert-equal(123, element(t1, "a", default: 123));
  t1["a"] := 11;
  assert-equal(11, t1["a"]);

  t1["abc"] := 22;
  assert-equal(22, t1["abc"]);

  let (v, n) = t1.size;
  assert-equal(2, v, "2 values were inserted");
  assert-equal(4, n, "4 nodes were created");
end test;

define test test-string-trie ()
  let t1 = make(<string-trie>);
  let k = #["a", "b", "c"];
  t1[k] := 666;
  assert-equal(666, t1[k], "key with strings that are ==");
  assert-equal(666, t1[map(copy-seq, k)], "key with strings that are not ==");
  assert-signals(<trie-element-error>,
                 t1[#("A", "b", "C")],
                 "key with strings that are not =");
end test;

define test test-istring-trie ()
  let t1 = make(<istring-trie>);
  let k = #["a", "b", "c"];
  t1[k] := 666;
  assert-equal(666, t1[k], "key with strings that are ==");
  assert-equal(666, t1[#("A", "b", "C")], "key with strings that are not =");
end test;

define function lorem-ipsumize (trie)
  let lorem = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
    exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
    dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
    pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
    deserunt mollit anim id est laborum.
    """;
  for (line in split(lorem, '\n'))
    for (word in split(line, ' '))
      trie[word] := 1 + element(trie, word, default: 0);
    end;
  end;
  trie
end function;

define test test-case-sensitive-word-counts ()
  let trie = lorem-ipsumize(make(<trie>));
  // Spot check
  assert-equal(1, trie["est"]);
  assert-equal(2, trie["dolor"]);
  assert-equal(2, trie["dolore"]);
  assert-equal(3, trie["in"]);
  assert-signals(<trie-element-error>, trie["lorem"]);
  assert-equal(1, trie["Lorem"]);
end test;

define test test-case-insensitive-word-counts ()
  let trie = lorem-ipsumize(make(<ichar-trie>));
  assert-equal(1, trie["est"]);
  assert-equal(2, trie["dolor"]);
  assert-equal(2, trie["dolore"]);
  assert-equal(3, trie["in"]);
  assert-equal(1, trie["lorem"]);
  assert-equal(1, trie["Lorem"]);
end test;

define test test-traverse ()
  let trie = lorem-ipsumize(make(<ichar-trie>));
  let found-voluptate? = #f;
  traverse(method (node, depth, key)
             //let indent = make(<string>, fill: ' ', size: 2 * depth);
             //test-output("%s%= => %= %=\n", indent, key, node, node.node-value);
             let key = as(<string>, key);
             if (key = "voluptate")
               found-voluptate? := #t
             end;
           end,
           trie, keys?: #t);
  assert-true(found-voluptate?)
end test;

define test test-forward-iteration-protocol ()
  for (v keyed-by k in lorem-ipsumize(make(<ichar-trie>)))
    if (as(<string>, k) = "voluptate")
      assert-equal(1, v);
    end;
  end;
end test;
