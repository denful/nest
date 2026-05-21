{ nest, ... }:
{
  nest.default = {
    is = [ nest.shell ];
    system = "x86_64-linux";
  };
}
