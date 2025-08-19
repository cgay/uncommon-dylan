Module: uncommon-dylan-test-suite


define enum-class <planet> (<object>)
  constant slot %name :: <string>, required-init-keyword: name:;
  constant slot %mass :: <float>,  required-init-keyword: mass:;
  $mercury (name: "Mercury", mass: 1.1);
  $venus   (name: "Venus",   mass: 3.3);
  $mars    (name: "Mars",    mass: 5.5);
end;

define test test-enum-class-definer ()
  assert-instance?(<planet>, $mercury);
  assert-equal("Mercury", $mercury.%name);
  assert-equal(1.1, $mercury.%mass);
  assert-equal(list($mercury, $venus, $mars),
               $planet-instances,
               "planet instances are in definition order");
end test;


define enum nato-alphabet ()
  $alpha; $bravo; $charlie;
end;

define test test-simple-enum ()
  assert-equal(1, $alpha);
  assert-equal(2, $bravo);
  assert-equal(3, $charlie);
  assert-equal(#["$alpha", "$bravo", "$charlie"], $nato-alphabet-names);
  assert-equal(#[1, 2, 3],                        $nato-alphabet-values);
end;


define enum color ()
  // One of each possible clause form...
  $red;                // defines $color-red   :: <int> = 1  with name "$red"
  $green = 20;         // defines $color-green :: <int> = 20 with name "$green"
  $blue        "Blue"; // defines $color-blue  :: <int> = 21 with name "Blue"
  $cyan = 30   "Cyan"; // defines $color-cyan  :: <int> = 30 with name "Cyan"
end;

define test test-enum-definer ()
  assert-equal(1, $red);
  assert-equal("$red", color-to-name($red));
  assert-equal(1, name-to-color("$red"));

  assert-equal(20, $green);
  assert-equal("$green", color-to-name($green));
  assert-equal(20, name-to-color("$green"));

  assert-equal(21, $blue);
  assert-equal("Blue", color-to-name($blue));
  assert-equal(21, name-to-color("Blue"));

  assert-equal(30, $cyan);
  assert-equal("Cyan", color-to-name($cyan));
  assert-equal(30, name-to-color("Cyan"));

  assert-equal(vector($red, $green, $blue, $cyan), $color-values);
  assert-equal(vector("$red", "$green", "Blue", "Cyan"), $color-names);
end test;
