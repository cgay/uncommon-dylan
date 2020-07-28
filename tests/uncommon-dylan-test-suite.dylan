Module: uncommon-dylan-test-suite


define test test-count ()
  let seq = #[1, 2, 2, 3, 3, 3];
  assert-equal(0, count(#[], curry(\=, #f)));
  assert-equal(0, count(seq, curry(\=, #f)));
  assert-equal(1, count(seq, curry(\=, 1)));
  assert-equal(2, count(seq, curry(\=, 2)));
  assert-equal(3, count(seq, curry(\=, 3)));
  assert-equal(555, count(seq, curry(\=, 3), limit: 2));
end;


define test test-ash<< ()
  // Shouldn't be able to pass a negative count.
  assert-signals(<error>, ash<<(1, -1));
  assert-signals(<error>, ash>>(1, -1));

  assert-equal(ash<<(1, 3), ash(1, 3));
  assert-equal(ash>>(1, 3), ash(1, -3));
end;

//// "define enum"
/*
define enum <error-type> ()
  $parse-error = 1;
  $unbound-variable-error = 2;
end;

define test test-error-type ()
  assert-equal(1, enum-value($parse-error));
  assert-equal(2, enum-value($unbound-variable-error));
  assert-equal("$parse-error :: <error-type>", enum-description($parse-error));
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
*/
run-test-application();
