{
  nest.rules = {

    # Tux on both Standalone-HM and Hosted-HM
    "#tux" = {
      homeManager =
        # Since this is a generic Standalone/Hosted rule,
        # we access `node` instead of `user` or `home` trait-specific args.
        { pkgs, node, ... }:
        {
          programs.emacs.enable = true;
          programs.emacs.package = pkgs.emacs-nox;
          programs.emacs.extraConfig = ''(setq user-name "${node.name}")'';
        };
    };

    # Tux only on Hosted-HM
    "host #tux" = {
      homeManager =
        # Since this is a Hosted-HM specific rule,
        # we can access `user` and `host` instead of `node`.
        #
        # user is the matched node with `tux` name.
        # host is the parent node with `host` trait.
        #
        # it works like this: any function arg is looked up as
        # current or the closest parent node with that trait name,
        # or if not found, the argument is deferred to module evaluation.
        { user, host, ... }:
        {
          programs.emacs.extraConfig = ''(setq user-email "${user.name}@${host.name}")'';
        };
    };

    # Tux presence contributes to host
    "host:has(#tux)" = {
      nixos.services.displayManager.autoLogin.user = "tux";
    };

  };
}
