Module: uncommon-dylan-test-suite

define enum <result> ()
  $result-passed;
  $result-failed;
  $result-crashed = 5;
  $result-not-implemented;
end enum;

define test test-enum-basics ()
  assert-instance?(<result>, $result-passed);
  assert-equal(1, $result-passed.result-value);
  assert-equal("$result-passed", $result-passed.result-name);

  assert-equal(2, $result-failed.result-value);
  assert-equal("$result-failed", $result-failed.result-name);

  assert-equal(5, $result-crashed.result-value);
  assert-equal("$result-crashed", $result-crashed.result-name);

  assert-equal(6, $result-not-implemented.result-value);
  assert-equal("$result-not-implemented", $result-not-implemented.result-name);
end test;
