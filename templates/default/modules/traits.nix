# This is an starting point for defining your traits and how they work.
# Traits are not hardcoded in Nest, you can define your own
# trait names as well as your own DOM structure.
#
# Traits define the kind of configurable entities we have and
# the Nix classes they use and how each class configuration is
# made available to upper layers.
#
# For example, the `host` trait's `nixos` class creates a
# NixOS instance from all its received inner modules, making
# the resulting configuration available to upper layers.
#
#
# Similarly, standalone `home` trait creates an instance of
# HomeManager by providing a nixpkgs instance to it.
#
# Users are a nested trait inside Hosts, and they have two classes:
#
# - `user` forwards into `nixos.users.users.<username>`
# - `homeManager` forwards into `nixos.home-manager.users.<username>`
#
# The `user` class also provides arguments from the os-configuration into
# the "user" sub-modules, along with osConfig.
#
# Any `nixos` configuration created by User nodes gets propagated to their
# parents up to the Host level.
{
  inputs,
  ...
}:
{

  nest.trait.host.class.nixos =
    # select can be used to query the current node or other nodes in DOM
    select: modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (select.node) system;
      inherit modules;
    };

  nest.trait.host.user.class = {
    homeManager = select: modules: {
      # simply forward the modules to the right place in the nixos config
      nixos.home-manager.users."${select.node.name}".imports = modules;
    };

    # A "lightweight" home environment available in NixOS and Darwin
    user = select: modules: {
      nixos =
        { pkgs, config, ... }:
        {
          users.users.${select.node.name} =
            # need function args to be able to use module imports
            { ... }:
            {
              imports = modules ++ [
                {
                  # make pkgs and osConfig available
                  _module.args.pkgs = pkgs;
                  _module.args.osConfig = config;
                }
              ];
            };
        };
    };
  };

  # Standalone homes, any extraSpecialArgs would be added here
  nest.trait.home.class.homeManager =
    select: modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${select.node.system};
      inherit modules;
    };
}
