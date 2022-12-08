let
  nixos = import <nixpkgs/nixos> {
    configuration = import ./installer-configuration.nix { };
  };
in
nixos.config.system.build.isoImage
