{ inputs, ... }:
{
  # Host config ONLY when it has at least a HM user
  nest.rules."host:has(.homeManager)" = {
    nixos = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
    };
  };

  # host provides defaults for ALL its hm users
  nest.rules."host .homeManager" = {
    homeManager.programs.direnv.enable = true;
    user =
      # See comments on tux.nix for how function args are looked up.
      { user, host, ... }:
      {
        description = "${user.name}@${host.name}";
      };
  };
}
