{
  outputs = _: {
    lib = import ./.;
    module = ./module.nix;
    flakeModule = ./module.nix;
    flakeModules.default = ./module.nix;
    modules.flake.default = ./module.nix;
    templates = {
      default = {
        path = ./templates/default;
        description = "Default nest starter: host + standalone home-manager user";
      };
      flake-file = {
        path = ./templates/flake-file;
        description = "Minimal flake-based template";
      };
      flake-parts-modules = {
        path = ./templates/flake-parts-modules;
        description = "Template using flake-parts modules";
      };
      fleet-demo = {
        path = ./templates/fleet-demo;
        description = "Fleet demo template";
      };
      minimal = {
        path = ./templates/minimal;
        description = "Minimal nest template";
      };
      selectors-demo = {
        path = ./templates/selectors-demo;
        description = "Selector algebra showcase: every selector form, tested";
      };
      noflake = {
        path = ./templates/noflake;
        description = "Template without flakes";
      };
      nvf-standalone = {
        path = ./templates/nvf-standalone;
        description = "Standalone NeoVim Framework template";
      };
      terranix-demo = {
        path = ./templates/terranix-demo;
        description = "Terranix demo template";
      };
    };
  };
}
