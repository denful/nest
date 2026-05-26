nest:
let
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
        nest.parseStar rest self
      else if c == "#" then
        nest.parseId str self
      else if c == "." then
        nest.parseClass str self
      else if c == "&" then
        nest.parseCurrent str self
      else if c == "(" then
        nest.parseParen str self
      else if c == "[" then
        nest.parseAttr str self
      else if c == ":" then
        nest.parsePseudo str self
      else
        nest.parseName str self;
in
{
  inherit len splitOn trim;
  parseCompound = self;
}
