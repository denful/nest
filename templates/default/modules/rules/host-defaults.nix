{
  nest.rules = {

    # Defaults for all nodes of `host` trait.
    "host" = {
      nixos.system.stateVersion = "25.11";
    };

    "host[boot=false]" = {
      nixos = {
        boot.loader.grub.enable = false;
        fileSystems."/".device = "/dev/null";
        fileSystems."/".fsType = "auto";
      };
    };
  };
}
