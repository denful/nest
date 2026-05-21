_nest:
# Integration tests for flakeModule.nix — verify evalModules integration
let
  nixpkgs = import <nixpkgs> { };
  inherit (nixpkgs) lib;
  flakeModule = import ../module.nix;

  # Standalone compat: declare flake output options that flake-parts provides in
  # flake-parts mode but are absent in plain lib.evalModules.
  standaloneFlakeOptions =
    { lib, config, ... }:
    {
      options.flake.nixosConfigurations = lib.mkOption {
        default = { };
        type = lib.types.lazyAttrsOf lib.types.raw;
      };
      options.flake.homeConfigurations = lib.mkOption {
        default = { };
        type = lib.types.lazyAttrsOf lib.types.raw;
      };
      options.flake.darwinConfigurations = lib.mkOption {
        default = { };
        type = lib.types.lazyAttrsOf lib.types.raw;
      };
      # User-defined routing: map class names to flake outputs
      config.flake = {
        nixosConfigurations = config.flake.nest.evalResult.byClass.nixos or { };
        homeConfigurations = config.flake.nest.evalResult.byClass.homeManager or { };
        darwinConfigurations = config.flake.nest.evalResult.byClass.darwin or { };
      };
    };

  evalWithModule =
    modules:
    (lib.evalModules {
      modules = [
        flakeModule
        standaloneFlakeOptions
      ]
      ++ modules;
    }).config.flake;
in
{
  flakeModule = {

    test-nixos-configurations-produced = {
      expr =
        builtins.attrNames
          (evalWithModule [
            (
              { nest, ... }:
              {
                nest.trait.host.class.nixos = _: modules: { cfg = builtins.foldl' (a: b: a // b) { } modules; };
                nest.prod.igloo = {
                  is = [ nest.host ];
                  system = "x86_64-linux";
                };
                nest.rules = [
                  {
                    is = nest.host;
                    nixos.x = 1;
                  }
                ];
              }
            )
          ]).nixosConfigurations;
      expected = [ "igloo" ];
    };

    test-nixos-config-value = {
      expr =
        (evalWithModule [
          (
            { nest, ... }:
            {
              nest.trait.host.class.nixos = _: modules: { val = builtins.foldl' (a: b: a // b) { } modules; };
              nest.prod.igloo = {
                is = [ nest.host ];
                system = "x86_64-linux";
              };
              nest.rules = [
                {
                  is = nest.host;
                  nixos.magic = 42;
                }
              ];
            }
          )
        ]).nixosConfigurations.igloo.val.magic;
      expected = 42;
    };

    test-multiple-hosts = {
      expr = builtins.length (
        builtins.attrNames
          (evalWithModule [
            (
              { nest, ... }:
              {
                nest.trait.host.class.nixos = _: modules: { cfg = builtins.foldl' (a: b: a // b) { } modules; };
                nest.prod.web-1 = {
                  is = [ nest.host ];
                  system = "x86_64-linux";
                };
                nest.prod.web-2 = {
                  is = [ nest.host ];
                  system = "x86_64-linux";
                };
                nest.prod.lb = {
                  is = [ nest.host ];
                  system = "x86_64-linux";
                };
                nest.rules = [ ];
              }
            )
          ]).nixosConfigurations
      );
      expected = 3;
    };

    test-nest-proxy-accessible = {
      # nest should be accessible as module arg
      expr =
        (evalWithModule [
          (
            { nest, ... }:
            {
              nest.trait.host.class.nixos = _: _: { traitName = nest.host.__path; };
              nest.prod.igloo = {
                is = [ nest.host ];
                system = "x86_64-linux";
              };
              nest.rules = [ ];
            }
          )
        ]).nixosConfigurations.igloo.traitName;
      expected = [ "host" ];
    };

    test-byclass-routing = {
      # homeManager class routes to homeConfigurations
      expr =
        builtins.attrNames
          (evalWithModule [
            (
              { nest, ... }:
              {
                nest.trait.home.class.homeManager = _node: cfg: { inherit cfg; };
                nest.homes.alice = {
                  is = [ nest.home ];
                  system = "x86_64-linux";
                };
                nest.rules = [
                  {
                    is = nest.home;
                    homeManager.shell = "fish";
                  }
                ];
              }
            )
          ]).homeConfigurations;
      expected = [ "alice" ];
    };

    test-rules-span-modules = {
      # Rules from multiple modules get merged
      expr =
        (evalWithModule [
          (
            { nest, ... }:
            {
              nest.trait.host.class.nixos = _: modules: { cfg = builtins.foldl' (a: b: a // b) { } modules; };
              nest.prod.igloo = {
                is = [ nest.host ];
                system = "x86_64-linux";
              };
            }
          )
          (
            { nest, ... }:
            {
              nest.rules = [
                {
                  is = nest.host;
                  nixos.from-module-2 = true;
                }
              ];
            }
          )
        ]).nixosConfigurations.igloo.cfg.from-module-2;
      expected = true;
    };

  };
}
