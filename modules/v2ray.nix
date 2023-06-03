{ ... }:
{
  services.v2ray = {
    enable = true;
    configFile = builtins.toString ./v2ray.json;
  };
}
