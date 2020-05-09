Module: uncommon-utils

// See tests/test-enum.dylan for examples.

define class <enum-error> (<error>) end;

define dynamic abstract class <enum> (<object>)
  // This slot is set to #f after the last instance is created since it's only
  // needed to detect duplicate values during initialization.
  constant each-subclass slot %used-values = make(<stretchy-vector>);
end;

// Signal <enum-error> if a value is used twice in one enum definition.
// No need to check whether names are used twice since the compiler will warn.
define method initialize (enum :: <enum>, #rest args, #key value :: <int>)
  next-method();
  if (member?(value, %used-values(enum)))
    error(make(<enum-error>,
               format-string: "Value %d used twice in enum %s",
               format-arguments: list(value, enum.object-class)))
  end;
  add!(%used-values(enum), value);
end method;

define macro enum-definer
  { define enum "<" ## ?enum-name:name ## ">" () // TODO: allow names without <>
      ?clauses:*                // TODO: at least one should be required
    end
  } => { define generic ?enum-name ## "-value"
             (enum-instance :: "<" ## ?enum-name ## ">") => (v :: <int>);
         define generic ?enum-name ## "-name"
             (enum-instance :: "<" ## ?enum-name ## ">") => (n :: <string>);
         ignorable(?enum-name ## "-name");

         define class "<" ## ?enum-name ## ">" (<enum>)
             constant slot ?enum-name ## "-value" :: <int>, required-init-keyword: value:;
             constant slot ?enum-name ## "-name" :: <string>, required-init-keyword: name:;
         end;

         define enum-constants "<" ## ?enum-name ## ">", 0, ?clauses end;
         // TODO: %clear-used-values(...)
       }
end macro;

define macro enum-constants-definer
  { define enum-constants ?class:name, ?max:expression end } => { }

  { define enum-constants ?class:name, ?max:expression, ?:name;
      ?more:* 
    end }
    => { define enum-constants ?class, ?max, ?name = ?max; ?more end }

  { define enum-constants ?class:name, ?max:expression, ?:name = ?value:expression ;
      ?more:*
    end }
    => { define constant ?name :: ?class
           = make(?class, value: ?value, name: ?"name");
         define enum-constants ?class, (?value + 1), ?more end;
       }
end macro;
