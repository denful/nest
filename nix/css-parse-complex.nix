nest: {
  parseParen =
    str: self:
    let
      m = builtins.match "\\(([^)]*)\\)(.*)" str;
    in
    [ (nest.parseCssSel (nest.trim (builtins.elemAt m 0))) ] ++ self (builtins.elemAt m 1);

  parseAttr =
    str: self:
    let
      rest = builtins.substring 1 (-1) str;
      attrParts = nest.splitOn "]" rest;
      inner = builtins.elemAt attrParts 0;
      after = if nest.len attrParts > 1 then builtins.elemAt attrParts 1 else "";
      eqParts = nest.splitOn "=" inner;
    in
    if nest.len eqParts > 1 then
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
