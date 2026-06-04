# Trait definitions for the flake-parts-modules template.
# KEY CONCEPT: synth runs BEFORE classes — use it to derive node data once.
{ inputs, ... }:
{
  # `synth` is a function `{ node, ... } -> { node.<extra attrs> }`.
  # Here it resolves node.pkgs from inputs.nixpkgs for node.system.
  # WHY synth: rules.nix needs pkgs — synth computes it once per node,
  # avoiding duplication across every rule/class that would otherwise
  # have to thread `inputs` and `system` themselves.
  nest.trait.shell.synth =
    { node, ... }:
    {
      node.pkgs = inputs.nixpkgs.legacyPackages.${node.system};
    };

  # `devshell` class: receives _select (unused here) + modules list.
  # Wraps all class contributions as devshell `imports`.
  # byClass.devshell feeds perSystem.devshells in outs.nix.
  nest.trait.shell.class.devshell = _select: modules: { imports = modules; };
}
