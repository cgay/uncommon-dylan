Module: uncommon-utils

// ----------------------------------------------------------------------
// Convert a string to a floating point number.
// This version is from Chris Double's dylanlibs project, and
// seems to be the most precise of the three.  I renamed it
// from formatted-string-to-float to string-to-float.  I added
// min(..., 7) in a couple places as a quick kludge to keep from
// getting integer overflow errors.  Should figure out the right
// way...  -cgay
//
define method string-to-float(s :: <string>) => (f :: <float>)
  local method is-digit?(ch :: <char>) => (b :: <bool>)
    let v = as(<int>, ch);
    v >= as(<int>, '0') & v <= as(<int>, '9');
  end method;
  let lhs = make(<stretchy-vector>);
  let rhs = make(<stretchy-vector>);
  let state = #"start";
  let sign = 1;

  local method process-char(ch :: <char>)
    select (state)
      #"start" =>
        select (ch)
          '-' =>
            begin
              sign := -1;
              state := #"lhs";
            end;
          '+' =>
            begin
              sign := 1;
              state := #"lhs";
            end;
          '.' =>
            begin
              lhs := add!(lhs, '0');
              state := #"rhs";
            end;
          otherwise =>
            begin
              state := #"lhs";
              process-char(ch);
            end;
        end select;
      #"lhs" =>
        case
          is-digit?(ch) => lhs := add!(lhs, ch);
          ch == '.' => state := #"rhs";
          otherwise => error("Invalid floating point value.");
        end case;
      #"rhs" =>
        case
          is-digit?(ch) => rhs := add!(rhs, ch);
          otherwise => error("Invalid floating point value.");
        end case;
      otherwise => error("Invalid state while parsing floating point.");
    end select;
  end method;

  for (ch in s)
    process-char(ch);
  end for;

  let lhs = as(<string>, lhs);
  let rhs = iff(empty?(rhs), "0", as(<string>, rhs));
  (string-to-integer(lhs) * sign)
   + as(<double-float>, string-to-integer(rhs) * sign)
     / (10 ^ min(rhs.size, 7));
end method string-to-float;

// Convert a floating point to a string without the Dylan specific formatting.
// Prints to the given number of decimal places.
// Written by Chris Double, as part of dylanlibs.
//
define method float-to-formatted-string
    (value :: <float>, #key decimal-places)
 => (s :: <string>)
  let value = iff(decimal-places,
                  as(<double-float>, truncate(value * 10 ^ min(decimal-places, 7))) / 10d0 ^ decimal-places,
                  value);
  let s = float-to-string(value);
  let dp = subsequence-position(s, ".");
  let tp = subsequence-position(s, "d") | subsequence-position(s, "s") | s.size;
  let lhs = slice(s, 0, dp);
  let rhs = slice(s, dp + 1, tp);
  let shift = if (tp = s.size) 0  else string-to-integer(s, start: tp + 1) end;
  let result = "";
  let temp = concat(lhs, rhs);
  let d = lhs.size - 1 + shift;
  if (shift < 0)
    for (n from 0 below abs(shift))
      temp := concat("0", temp);
    end for;
    d := 0;
  elseif (shift > 0)
    for (n from 0 below shift)
      temp := concat(temp, "0");
    end for;
    d := temp.size;
  end if;

  let tsize = temp.size;
  concat(slice(temp, 0, min(d + 1, tsize)),
         iff(d = tsize, "", "."),
         iff(d = tsize,
             "",
             slice(temp,
                   d + 1,
                   iff(decimal-places,
                       min(d + 1 + decimal-places, tsize),
                       tsize))));
end method float-to-formatted-string;
