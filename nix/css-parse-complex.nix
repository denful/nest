nest:
let
  splitOn = pat: str: builtins.filter builtins.isString (builtins.split pat str);
in
{
  parseParen =
    str: self:
    let
      m = builtins.match "\\(([^)]*)\\)(.*)" str;
    in
    [ (nest.parseCssSel (nest.trim (builtins.elemAt m 0))) ] ++ self (builtins.elemAt m 1);

  parseAttr =
    str: self:
    let
      len = builtins.length;
      rest = builtins.substring 1 (-1) str;
      attrParts = splitOn "]" rest;
      inner = builtins.elemAt attrParts 0;
      after = if len attrParts > 1 then builtins.elemAt attrParts 1 else "";
      eqParts = splitOn "=" inner;
    in
    if len eqParts > 1 then
      [
        {
          __sel = "attr";
          key = builtins.elemAt eqParts 0;
          val = builtins.elemAt eqParts 1;
        }
      ]
      ++ self after
    else
      [
        {
          __sel = "attrExists";
          key = inner;
        }
      ]
      ++ self after;

  parsePseudo =
    str: self:
    let
      m = builtins.match ":([a-z-]+)\\((.*)\\)(.*)" str;
    in
    [
      {
        __sel = builtins.elemAt m 0;
        selector = nest.parseCssSel (builtins.elemAt m 1);
      }
    ]
    ++ self (builtins.elemAt m 2);
}
