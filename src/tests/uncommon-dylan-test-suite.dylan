Module: uncommon-dylan-test-suite


define test test-count ()
  let seq = #[1, 2, 2, 3, 3, 3];
  assert-equal(0, count(#[], curry(\=, #f)));
  assert-equal(0, count(seq, curry(\=, #f)));
  assert-equal(1, count(seq, curry(\=, 1)));
  assert-equal(2, count(seq, curry(\=, 2)));
  assert-equal(3, count(seq, curry(\=, 3)));
end;


define test test-ash<< ()
  // Shouldn't be able to pass a negative count.
  assert-signals(<error>, ash<<(1, -1));
  assert-signals(<error>, ash>>(1, -1));

  assert-equal(ash<<(1, 3), ash(1, 3));
  assert-equal(ash>>(1, 3), ash(1, -3));
end;

define test test-iff ()
  assert-true(iff(#t, #t, #f));
  assert-true(iff(#t, #t));
  assert-true(iff(#f, #f, #t));

  assert-false(iff(#f, #t, #f));
  assert-false(iff(#f, #t));
  assert-false(iff(#t, #f, #t));
end test;
