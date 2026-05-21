{ inputs, ... }:
{
  nest.trait.shell.synth =
    { node, ... }:
    {
      node.pkgs = inputs.nixpkgs.legacyPackages.${node.system};
    };

  nest.trait.shell.class.devshell = _select: modules: { imports = modules; };
}
