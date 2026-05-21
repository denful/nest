{ nest, ... }:
{
  nest.web-1 = {
    is = [ nest.server ];
    serverType = "cx11";
    region = "nbg1";
  };

  nest.web-2 = {
    is = [ nest.server ];
    serverType = "cx21";
    region = "fsn1";
  };
}
