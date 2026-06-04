# Rules: apply devshell config to every `shell`-trait node.
# `select.node.pkgs` is available here because synth ran first (see traits.nix).
{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.shell; # matches every node with the `shell` trait
      devshell =
        { select, ... }:
        {
          commands = [
            # pkgs already resolved per-node by synth — no need to thread inputs here
            { package = select.node.pkgs.hello; }
          ];
        };
    }
  ];
}
