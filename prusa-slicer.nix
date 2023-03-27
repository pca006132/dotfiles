{ pkgs ? import <nixpkgs> { }, }:

let name = "prusa-slicer";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = builtins.fetchurl {
    url = "https://github.com/prusa3d/PrusaSlicer/releases/download/version_2.6.0-alpha5/PrusaSlicer-2.6.0-alpha5+linux-x64-GTK2-202303061452.AppImage";
    sha256 = "14xfig3xxbj0km499fcb5xb0p2y06p0v2lx4r6wx8i4v2gzh3g5i";
  };
}

