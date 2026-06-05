_nest: {
  parseStar = rest: self: [ { __sel = "star"; } ] ++ self rest;

  parseId =
    str: self:
    let
      m = builtins.match "#([a-zA-Z0-9_/-]+)(.*)" str;
    in
    [
      {
        __sel = "id";
        name = builtins.elemAt m 0;
      }
    ]
    ++ self (builtins.elemAt m 1);

  parseClass =
    str: self:
    let
      m = builtins.match "\\.([a-zA-Z0-9_/-]+)(.*)" str;
    in
    [
      {
        __sel = "class";
        name = builtins.elemAt m 0;
      }
    ]
    ++ self (builtins.elemAt m 1);

  parseCurrent =
    str: self:
    let
      rest = builtins.substring 1 (-1) str;
    in
    [ { __sel = "current"; } ] ++ self rest;

  parseName =
    str: self:
    let
      m = builtins.match "([a-zA-Z0-9_/-]+)(.*)" str;
    in
    if m != null then
      [
        {
          __sel = "name";
          name = builtins.elemAt m 0;
        }
      ]
      ++ self (builtins.elemAt m 1)
    else
      [ ];
}
