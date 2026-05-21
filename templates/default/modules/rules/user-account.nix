{
  nest.rules = {
    # Selector means:
    # On each node that produces `user` Nix class inside a `host`-trait node.
    "host .user" = {
      user =
        # `user` (automatically injected) is the node with `user` trait.
        #  pkgs is provided by the host, see traits.nix for details.
        { user, pkgs, ... }:
        {
          isNormalUser = true;
          home = "/home/${user.name}";
          packages = [ pkgs.bat ];
        };
    };

    "host .user[admin=true]" = {
      user.extraGroups = [ "wheel" ];
    };
  };
}
