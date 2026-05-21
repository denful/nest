nest:
let
  atoms = import ./css-parse-atoms.nix nest;
  complex = import ./css-parse-complex.nix nest;

  len = builtins.length;
  splitOn = pat: str: builtins.filter builtins.isString (builtins.split pat str);
  trim =
    s:
    let
      m = builtins.match " *(.*[^ ]) *" s;
    in
    if m == null then s else builtins.elemAt m 0;

  self =
    str:
    if str == "" then
      [ ]
    else
      let
        c = builtins.substring 0 1 str;
        rest = builtins.substring 1 (-1) str;
      in
      if c == "*" then
        atoms.parseStar rest self
      else if c == "#" then
        atoms.parseId str self
      else if c == "." then
        atoms.parseClass str self
      else if c == "&" then
        atoms.parseCurrent str self
      else if c == "(" then
        complex.parseParen str self
      else if c == "[" then
        complex.parseAttr str self
      else if c == ":" then
        complex.parsePseudo str self
      else
        atoms.parseName str self;
in
{
  inherit len splitOn trim;
  parseCompound = self;
}
