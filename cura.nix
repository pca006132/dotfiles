{ pkgs ? import <nixpkgs> { }, }:

pkgs.appimageTools.wrapType2 {
  name = "cura-5.2";
  src = builtins.fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/5.2.1/Ultimaker-Cura-5.2.1-linux-modern.AppImage";
    sha256 = "0f2x8rv795c66vlac2231ywf5f674x0kgmdg8z3fgmggca7cl46i";
  };
}
