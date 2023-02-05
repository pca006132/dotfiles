{ pkgs ? import <nixpkgs> { }, }:

let name = "cura-5.3";
in
pkgs.appimageTools.wrapType2 {
  name = "cura-5.3";
  src = builtins.fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/5.3.0-alpha%2Bxmas/UltiMaker-Cura-5.3.0-alpha+xmas-linux.AppImage";
    sha256 = "1c06la2b0axgjdr0si4243qw8f992577jnhknrksdrzxn0492bz7";
  };
}
