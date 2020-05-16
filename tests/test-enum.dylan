Module: uncommon-dylan-test-suite

define enum <result> ()
  $result-passed;
  $result-failed;
  $result-crashed;
end enum;

define test test-enum-basics ()
  assert-instance?(<result>, $result-passed);
  assert-instance?(<result>, $result-failed);
  assert-instance?(<result>, $result-crashed);
  assert-equal("$result-passed", $result-passed.result-name);
end test;
