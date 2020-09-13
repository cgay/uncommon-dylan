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

//// "define enum"

define enum <test-simple-enum> ()
  $alpha; $bravo; $charlie;
end;

define test test-simple-enum ()
  assert-instance?(<test-simple-enum>, $alpha);
  assert-equal(test-simple-enum-name($alpha), "$alpha");
  assert-equal(test-simple-enum-value($alpha), 1);

  assert-instance?(<test-simple-enum>, $bravo);
  assert-equal(test-simple-enum-name($bravo), "$bravo");
  assert-equal(test-simple-enum-value($bravo), 2);

  assert-instance?(<test-simple-enum>, $charlie);
  assert-equal(test-simple-enum-name($charlie), "$charlie");
  assert-equal(test-simple-enum-value($charlie), 3);
end;


run-test-application();
