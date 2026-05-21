nest:
let

  compound =
    str:
    let
      tokens = nest.parseCompound str;
    in
    if nest.len tokens == 0 then
      { __sel = "star"; }
    else if nest.len tokens == 1 then
      builtins.head tokens
    else
      tokens;

  orPartsFn = str: nest.splitOn "," str;
  normalizeCombinators = str: builtins.replaceStrings [ ">" "+" ] [ " > " " + " ] str;

  splitTokens = str: builtins.filter (t: t != "") (nest.splitOn " " (normalizeCombinators str));

  parseSequence =
    tokens:
    if nest.len tokens == 0 then
      { __sel = "star"; }
    else if nest.len tokens == 1 then
      compound (builtins.head tokens)
    else
      let
        head = builtins.head tokens;
        tail = builtins.tail tokens;
        operator = builtins.head tail;
        rest = builtins.tail tail;
      in
      if operator == ">" then
        {
          __sel = "child";
          parentSel = compound head;
          childSel = parseSequence rest;
        }
      else if operator == "+" then
        {
          __sel = "adjacent";
          previousSel = compound head;
          nextSel = parseSequence rest;
        }
      else
        {
          __sel = "descendant";
          ancestorSel = compound head;
          descendantSel = parseSequence tail;
        };

  parseCssSel =
    str:
    if nest.len (orPartsFn str) > 1 then
      {
        __sel = "or";
        selectors = map (p: parseCssSel (nest.trim p)) (orPartsFn str);
      }
    else
      let
        tokens = splitTokens str;
      in
      if nest.len tokens > 1 then parseSequence tokens else compound str;
in
{
  inherit parseCssSel;
}
