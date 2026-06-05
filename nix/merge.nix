nest:
let
  mergeRuleConfigs =
    node: rules: ctx:
    builtins.foldl' (
      acc: rule:
      let
        ruleAttrs = builtins.removeAttrs rule [ "is" ];
      in
      builtins.foldl' (
        a: key:
        let
          result =
            if builtins.isFunction rule.${key} then nest.callWithArgs rule.${key} node ctx else rule.${key};
        in
        if key == "synth" then
          a // { synth = nest.deepMerge (a.synth or { }) result; }
        else
          a // { ${key} = (a.${key} or [ ]) ++ [ result ]; }
      ) acc (builtins.attrNames ruleAttrs)
    ) { } rules;

  mergeModuleLists =
    a: b:
    builtins.foldl' (acc: k: acc // { ${k} = (a.${k} or [ ]) ++ (b.${k} or [ ]); }) { } (
      builtins.attrNames (a // b)
    );

  deepMerge =
    a: b:
    if !builtins.isAttrs a || !builtins.isAttrs b then
      b
    else if b == { } then
      a
    else if a == { } then
      b
    else
      a
      // builtins.listToAttrs (
        map (k: {
          name = k;
          value = if a ? ${k} then nest.deepMerge a.${k} b.${k} else b.${k};
        }) (builtins.attrNames b)
      );
in
{
  inherit mergeRuleConfigs mergeModuleLists deepMerge;
}
