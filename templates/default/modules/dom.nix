# Read after traits.nix.
#
# This is the infra DOM structure, it is a tree that marks some
# nodes with `is = traits...` and allow custom attributes on nodes.
#
# These attributes are inherited by lower nodes.
#
# Read rules/* after this file.
{ nest, ... }:
{
  nest.igloo = {
    is = [ nest.host ];
    system = "x86_64-linux";

    # Remove for real hardware.
    boot = false;

    # User HM
    tux = {
      is = [ nest.host.user ];
      admin = true;
    };
  };

  # standalone HM
  nest.tux = {
    is = [ nest.home ];
    system = "x86_64-linux";
  };
}
