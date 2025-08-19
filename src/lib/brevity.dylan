Module: uncommon-utils-impl


//// Abbrevs for names exported from the dylan module...

define constant <bool>  = <boolean>;
define function bool? (x) => (bool :: <bool>)
  instance?(x, <bool>)
end;

define constant <char>  = <character>;
define constant <char?> = false-or(<char>);
define function char? (object) => (bool :: <bool>)
  instance?(object, <char>)
end;

define constant <func>  = <function>;
define constant <func?> = false-or(<func>);
define function func? (object) => (bool :: <bool>)
  instance?(object, <func>)
end;

define constant <int>  = <integer>;
define constant <int?> = false-or(<int>);
define function int? (object) => (bool :: <bool>)
  instance?(object, <int>)
end;

define constant <seq>  = <sequence>;
define constant <seq?> = false-or(<seq>);
define function seq? (object) => (bool :: <bool>)
  instance?(object, <seq>)
end;

define constant <vector*>    = <stretchy-vector>;
define constant <vector*?>   = false-or(<vector*>);
define function vector*? (object) => (bool :: <bool>)
  instance?(object, <vector*>)
end;

define constant <string?> = false-or(<string>);
define function string? (object) => (bool :: <bool>)
  instance?(object, <string>)
end;

define constant <symbol?> = false-or(<symbol>);
define function symbol? (object) => (bool :: <bool>)
  instance?(object, <symbol>)
end;

define constant concat = concatenate;
define constant copy-seq = copy-sequence;

define constant $max-int = $maximum-integer;
define constant $min-int = $minimum-integer;
