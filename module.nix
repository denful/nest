# Module for vanilla Nix evalModules or flake-parts
{ lib, config, ... }:
let
  nestLib = import ./default.nix;
  processedTraits = nestLib.injectNames (config.nest.trait or { });
  nestProxy = processedTraits // nestLib.mkSelectors;

  nestCfg = config.nest;
  evalResult = nestLib.evalNest nestCfg;
in
{
  options = {
    nest = lib.mkOption {
      description = "nest CSS-for-Nix configuration";
      default = { };
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.anything;
        options = {
          trait = lib.mkOption {
            description = "Trait definitions (entity-type or marker)";
            default = { };
            type = lib.types.attrsOf lib.types.raw;
          };
          rules = lib.mkOption {
            description = "CSS rule list or attrset: [{ is = sel; cfg; }] or { \"sel\" = { cfg; }; }";
            default = [ ];
            # raw: preserves functionArgs metadata needed by callWithArgs
            type = lib.types.mkOptionType {
              name = "nestRules";
              description = "list or attrset of nest rules";
              check = v: builtins.isList v || builtins.isAttrs v;
              merge =
                _loc: defs:
                builtins.concatMap (
                  def:
                  if builtins.isList def.value then
                    def.value
                  else
                    map (k: { is = k; } // def.value.${k}) (builtins.attrNames def.value)
                ) defs;
            };
          };
        };
      };
    };

    # Custom nest flake output — flake-parts doesn't declare this
    # nixosConfigurations/homeConfigurations/darwinConfigurations intentionally
    # omitted: flake-parts core declares them; standalone use must provide them
    # via a compat module (see tests/flakeModule.nix).
    # raw: evalResult contains Nix functions/thunks that must not be type-traversed
    flake.nest = lib.mkOption {
      default = { };
      type = lib.types.raw;
    };
  };

  config = {
    # Pass nest proxy as module arg: nest = processedTraits // selectorConstructors
    _module.args.nest = nestProxy;

    flake.nest = {
      inherit evalResult nestCfg processedTraits;
      lib = nestLib;
    };
  };
}
