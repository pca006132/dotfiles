{ pkgs ? import <nixpkgs> { }, }:

let name = "prusa-slicer";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = builtins.fetchurl {
    url = "https://github.com/prusa3d/PrusaSlicer/releases/download/version_2.6.0-beta3/PrusaSlicer-2.6.0-beta3+linux-x64-GTK3-202305261352.AppImage";
    sha256 = "1f3wcz8089qip9f6zrhf1j7b2bmr25myk3pkwrlr01a8gxgwm2n6";
  };
}

