Module: uncommon-dylan-tests
Copyright: See LICENSE in this distribution for details.



define test test-count ()
  let seq = #[1, 2, 2, 3, 3, 3];
  assert-equal(0, count(#[], curry(\=, #f)));
  assert-equal(0, count(seq, curry(\=, #f)));
  assert-equal(1, count(seq, curry(\=, 1)));
  assert-equal(2, count(seq, curry(\=, 2)));
  assert-equal(3, count(seq, curry(\=, 3)));
  assert-equal(2, count(seq, curry(\=, 3), limit: 2));
end;


//// "define enum"

// minimal form, values assigned starting from 1
define enum <error-code-a> ()
  $parse-error-a;
  $connection-error-a;
end;

define test test-error-code-a ()
  assert-equal(1, enum-value($parse-error-a));
  assert-equal(2, enum-value($connection-error-a));
  assert-equal("$parse-error-a", enum-description($parse-error-a));
end;

// start values explicitly, they go up from there.
define enum <error-code-b> ()
  $parse-error-b = 0;
  $connection-error-b = 20;
end;

// add descriptions
define enum <error-code-c> ()
  $parse-error-c = 0, "parse error";
  $connection-error-c, "connection error";  
end;

run-test-application();
