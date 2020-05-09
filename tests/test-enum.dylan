Module: uncommon-dylan-test-suite

define enum <result> ()
  $result-passed;               // = 0
  $result-failed;               // = 1
  $result-crashed;              // = 2
end enum;

define enum <color> ()
  $color-red;                   // = 0
  $color-green = 3;
  $color-blue;                  // = 4
end enum;

define enum <option> ()
  $option-one = 100;
  $option-two = 200;
  $option-three = 300;
end enum;

define test test-enum-basics ()
  assert-instance?(<result>, $result-passed);

  assert-equal(0, $result-passed.result-value);
  assert-equal(1, $result-failed.result-value);
  assert-equal(2, $result-crashed.result-value);

  assert-equal("$result-passed", $result-passed.result-name);

  assert-equal(0, $color-red.color-value);
  assert-equal(3, $color-green.color-value);
  assert-equal(4, $color-blue.color-value);

  assert-equal(100, $option-one.option-value);
  assert-equal(200, $option-two.option-value);
  assert-equal(300, $option-three.option-value);

  // Duplicating a value in an enum should cause an error at load time but we
  // don't want that to happen for the test suite so just test it here rather
  // than in an actual "define enum" form.
  assert-signals(<enum-error>,
                 make(<result>, value: 0, name: "other"));
end test;
