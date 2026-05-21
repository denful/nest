{ lib, config, ... }:
let
  result = config.flake.nest.evalResult;
  igloo = config.flake.nixosConfigurations.igloo.config;
  tux = config.flake.homeConfigurations.tux.config;
  tuxUsr = igloo.users.users.tux;
  tuxHm = igloo.home-manager.users.tux;
in
{
  options.flake.tests = lib.mkOption { };
  config.flake.tests = {
    "test-igloo-nixos" = {
      expr = {
        hasIgloo = (result.byClass.nixos or { }) ? igloo;
      };
      expected = {
        hasIgloo = true;
      };
    };
    "test-igloo-nixos-config" = {
      expr = {
        grubEnable = igloo.boot.loader.grub.enable;
        rootDevice = igloo.fileSystems."/".device;
      };
      expected = {
        grubEnable = false;
        rootDevice = "/dev/null";
      };
    };
    "test-tux-home" = {
      expr = {
        hasTux = (result.byClass.homeManager or { }) ? tux;
      };
      expected = {
        hasTux = true;
      };
    };
    "test-tux-home-config" = {
      expr = {
        inherit (tux.home) stateVersion;
        inherit (tux.home) homeDirectory;
        emacs = lib.getName tux.programs.emacs.package;
        emacsHasUser = lib.hasInfix ''(setq user-name "tux")'' tux.programs.emacs.extraConfig;
      };
      expected = {
        stateVersion = "25.11";
        homeDirectory = "/home/tux";
        emacs = "emacs-nox";
        emacsHasUser = true;
      };
    };
    "test-igloo-nixos-home-manager-config" = {
      expr = {
        inherit (tuxHm.home) username;
        inherit (tuxHm.home) homeDirectory;
        direnv = tuxHm.programs.direnv.enable;
        emacsHasEmail = lib.hasInfix ''(setq user-email "tux@igloo")'' tuxHm.programs.emacs.extraConfig;
      };
      expected = {
        username = "tux";
        homeDirectory = "/home/tux";
        direnv = true;
        emacsHasEmail = true;
      };
    };
    "test-igloo-nixos-user-account" = {
      expr = {
        inherit (tuxUsr) isNormalUser;
        inherit (tuxUsr) home;
        inherit (tuxUsr) extraGroups;
        desc = tuxUsr.description;
        autoDm = igloo.services.displayManager.autoLogin.user;
        hasBat = lib.elem "bat" (map lib.getName tuxUsr.packages);
      };
      expected = {
        isNormalUser = true;
        home = "/home/tux";
        extraGroups = [ "wheel" ];
        desc = "tux@igloo";
        autoDm = "tux";
        hasBat = true;
      };
    };
    "test-separate-classes" = {
      expr = {
        classes = builtins.attrNames (result.byClass.nixos or { });
      };
      expected = {
        classes = [ "igloo" ];
      };
    };
  };
}
